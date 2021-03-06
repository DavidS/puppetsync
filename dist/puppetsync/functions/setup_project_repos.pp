# @ summary Read, clone, add facts, and filter repo Targets from the project's Puppetfile.repos file
#
# @return [Array[Target]] Project repo Targets
function puppetsync::setup_project_repos(
  Hash                 $puppetsync_config,
  Stdlib::Absolutepath $project_dir            = system::env('PWD'),
  Stdlib::Absolutepath $puppetfile             = "${project_dir}/Puppetfile.repos",
  Hash                 $options                = {},
){
  $opts = {
    'clone_git_repos'                      => true,
    'default_repo_moduledir'               => '_repos',
    'exclude_repos_from_other_module_dirs' => true,
  } + $options
  if $opts.dig('list_pipeline_stages') { return [] }

  $pf_repos = puppetsync::repo_targets_from_puppetfile(
    $puppetfile, 'repo_targets', $opts['default_repo_moduledir'], $opts['exclude_repos_from_other_module_dirs']
  )
  if $pf_repos.size == 0 { fail_plan( "No repos found to sync!  Is ${puppetfile} set up correctly?" ) }

  out::message( "== puppetfile: '${puppetfile}'\n== project_dir: '${project_dir}'" )
  warning( "\n\n==  \$puppetsync_config:\n${puppetsync_config.to_yaml.regsubst('^','    ','G')}" )

  if $opts['clone_git_repos'] {
    puppetsync::install_puppetfile(
      $project_dir, $puppetfile, $opts['default_repo_moduledir'], $opts['exclude_repos_from_other_module_dirs']
    )
    puppetsync::setup_repos_facts( $pf_repos )
    $repos = puppetsync::filter_permitted_repos( $pf_repos, $puppetsync_config )
  } else {
    warning( '' )
    warning( '== WARNING: **NOT** cloning git repos with `puppetsync::install_puppetfile` because \$opts["clone_git_repos"] = false!' )
    warning( '== WARNING: This speed up the start of plans and is probably fine outside of a ::sync, HOWEVER:' )
    warning( '== WARNING: This will stop puppetsync from downloading, adding facts, and fact-filtering repos (e.g., on project_type)' )
    warning( "== WARNING: If things go wrong, make SURE you didn't actually need facts or repo-filtering!" )
    warning( '' )
    $repos = $pf_repos
  }

  out::message(puppetsync::summarize_repo_targets($repos))
  warning(puppetsync::summarize_repo_targets($repos,true))

  $repos
}
