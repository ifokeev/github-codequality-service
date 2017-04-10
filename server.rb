require 'sinatra/base'

class App < Sinatra::Base
  before do
    content_type :json
  end

  get '/' do
    { success: true }.to_json
  end

  post '/pull_request_events' do
    @params = JSON.parse(request.body.read, symbolize_names: true)

    { success: perform_job || false }.to_json
  end

  private

  def perform_job
    AnalyzePullRequestJob.perform_async(@params) if should_analyze_pull_request?
  end

  def should_analyze_pull_request?
    %w[opened reopened synchronize].include?(@params[:action])
  end
end

class AnalyzePullRequestJob
  include SuckerPunch::Job
  workers 4

  attr_reader :data

  def perform(data)
    @data = data

    delete_previous_repos
    clone_repo
    analyze_repo
  end

  private

  def repos_path
    APP_ROOT + '/repos'
  end

  def delete_previous_repos
    FileUtils.rm_rf(Dir.glob("#{repos_path}/*"))
  end

  def cloned_repo_path
    @cloned_repo_path ||= "#{repos_path}/#{SecureRandom.hex}"
  end

  def clone_repo
    Rugged::Repository.clone_at(
      data[:repository][:clone_url],
      cloned_repo_path,
      checkout_branch: data[:pull_request][:head][:ref],
      credentials: credentials
    )
  end

  def pronto_formatters
    formatter = Pronto::Formatter::GithubFormatter.new
    status_formatter = Pronto::Formatter::GithubStatusFormatter.new

    [formatter, status_formatter]
  end

  def analyze_repo
    ENV['PULL_REQUEST_ID'] = data[:number]
    ENV['PRONTO_GITHUB_ACCESS_TOKEN'] = ENV['GITHUB_ACCESS_TOKEN']

    Pronto.run(
      'origin/master',
      cloned_repo_path,
      pronto_formatters
    )
  end

  def credentials
    @credentials ||= Rugged::Credentials::UserPassword.new(
      username: ENV['GITHUB_USERNAME'],
      password: ENV['GITHUB_PASSWORD']
    )
  end
end
