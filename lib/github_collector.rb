class GithubCollector
  def initialize user
    @user = user
    @stamps = Set.new
  end

  def get_commits
    @client = Octokit::Client.new(:access_token => @user.github_token)
    get_commits_from_my_repositories
    get_commits_from_my_organizations
    @stamps.to_a.sort {|x,y| y <=> x}
  end

  def get_commits_from_my_repositories
    @client.list_repositories.each do |repo|
      get_commits_from_all_branches repo
    end
  end

  def get_commits_from_my_organizations
    @client.list_organizations.each do |org|
      (@client.organization_repositories org.login).each do |repo|
        get_commits_from_all_branches repo
      end
    end
  end

  def get_commits_from_all_branches repo
    branches = @client.branches repo.full_name
    branches.each do |branch|
      get_commits_from_branch repo, branch
    end
  end

  def get_commits_from_branch repo , branch
    (CommitFetcher.new @client, repo, branch, @stamps).fetch
    puts @stamps.size
  end
  
end

class CommitFetcher
  def initialize client, repo, branch, stamps_collection
    @client = client
    @repo = repo
    @branch = branch
    @stamps_collection = stamps_collection
    @commits = []
  end

  def fetch
    @page = 1
    fetch_next_commit_page 
    while has_commits
      process_commits
      fetch_next_commit_page
    end
  end

  def has_commits
    not @commits.empty?
  end

  def process_commits
    @commits.each do |commit|
      stamp = commit[:commit][:author][:date]
      @stamps_collection << stamp
    end
  end

  def fetch_next_commit_page 
    retries = 0
    error = nil
    while retries < 3
      begin
        @commits = @client.commits  @repo.full_name, 
                          :sha => @branch.commit.sha,
                          :author => @client.user.login , 
                          :per_page => 100 , :page => @page
        @page += 1
        return
      rescue Exception => e
        retries += 1
        error = e
      end
    end
    raise error
  end
end