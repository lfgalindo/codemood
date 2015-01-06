class GithubCollector
  def initialize user
    @user = user
    @stamps = Set.new
  end

  def get_commits
    @client = Octokit::Client.new(:access_token => "dd31ee0db38bf7ce3d9d0b1f224b8019f3d40498")

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
    page = 1
    commits = fetch_commit_page repo, branch, page
    while not commits.empty?
      commits.each do |commit|
        stamp = commit[:commit][:author][:date]
        @stamps << stamp
      end
      page += 1
      commits = fetch_commit_page repo, branch, page
    end
  end

  def fetch_commit_page repo, branch, page
    @client.commits  repo.full_name, 
                      :sha => branch.commit.sha,
                      :author => @client.user.login , 
                      :per_page => 100 , :page => page
  end
end