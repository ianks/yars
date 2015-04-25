describe Yars::ConcurrentHashSet do
  let(:hash) { Yars::ConcurrentHashSet.new 20 }
  let(:data) do
    {
      'current_user_url' => 'https://api.legithub.com/user',
      'authorizations_url' => 'https://api.legithub.com/authorizations',
      'emails_url' => 'https://api.legithub.com/user/emails',
      'emojis_url' => 'https://api.legithub.com/emojis',
      'events_url' => 'https://api.legithub.com/events',
      'feeds_url' => 'https://api.legithub.com/feeds',
      'following_url' => 'https://api.legithub.com/user/following{/target}',
      'gists_url' => 'https://api.legithub.com/gists{/gist_id}',
      'hub_url' => 'https://api.legithub.com/hub',
      'issues_url' => 'https://api.legithub.com/issues',
      'keys_url' => 'https://api.legithub.com/user/keys',
      'notifications_url' => 'https://api.legithub.com/notifications',
      'organization_url' => 'https://api.legithub.com/orgs/{org}',
      'public_gists_url' => 'https://api.legithub.com/gists/public',
      'rate_limit_url' => 'https://api.legithub.com/rate_limit',
      'repository_url' => 'https://api.legithub.com/repos/{owner}/{repo}',
      'starred_url' => 'https://api.legithub.com/user/starred{/owner}{/repo}',
      'starred_gists_url' => 'https://api.legithub.com/gists/starred',
      'team_url' => 'https://api.legithub.com/teams',
      'user_url' => 'https://api.legithub.com/users/{user}',
      'user_organizations_url' => 'https://api.legithub.com/user/orgs'
    }
  end

  describe '[]=' do
    context 'single-threaded' do
      it 'can be pushed to' do
        data.each { |key, val| hash[key] = val }
        data.each { |key, val| expect(hash[key]).to eq val }
      end
    end

    context 'multi-threaded' do
      it 'can be pushed to' do
        threads = []

        8.times do
          threads << Thread.new do
            data.each { |key, val| hash[key] = val }
            data.each { |key, val| expect(hash[key]).to eq val }
          end
        end

        threads.each(&:join)
      end
    end
  end
end
