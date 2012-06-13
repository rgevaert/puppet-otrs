class otrs::cron {

  Cron {
    user        => 'otrs',
    ensure      => $otrs::cronjobs,
    environment => 'MAILTO="unixhelp@dict.ugent.be"',
  }

  cron {
    'delete expired cache weekly (Sunday mornings)':
    command => '$HOME/bin/otrs.DeleteCache.pl --expired >> /dev/null',
    minute  => 20,
    hour    => 0,
    weekday => 0;
  'load cache weekly (Sunday mornings)':
    command => '$HOME/bin/otrs.LoaderCache.pl -o delete >> /dev/null',
    minute  => 30,
    hour    => 0,
    weekday => 0;
  'start generic agent every 20 minutes':
    minute  => '*/20',
    command => '$HOME/bin/otrs.GenericAgent.pl >> /dev/null';
  'start generic agent every 10 minutes':
    minute  => '*/10',
    command => '$HOME/bin/otrs.GenericAgent.pl -c db >> /dev/null';
  'check every 120 min the pending jobs':
    minute  => 45,
    hour    => '*/2',
    command => '$HOME/bin/otrs.PendingJobs.pl >> /dev/null';
  'check daily the spool directory of OTRS':
    minute  => 10,
    hour    => 0,
    command => '$HOME/bin/otrs.cleanup >> /dev/null';
  'just every day':
    minute  => 1,
    hour    => 1,
    command => '$HOME/bin/otrs.RebuildTicketIndex.pl >> /dev/null';
  'delete every 120 minutes old/idle session ids':
    minute  => 55,
    hour    => '*/2',
    command => '$HOME/bin/otrs.DeleteSessionIDs.pl --expired >> /dev/null';
  'unlock every hour old locked tickets':
    minute  => 35,
    command => '$HOME/bin/otrs.UnlockTickets.pl --timeout >> /dev/null';
  'fetch emails every 10 minutes':
    minute  => '*/5',
    command => '$HOME/bin/otrs.PostMasterMailbox.pl >> /dev/null';
  # ############
  # ABSENT crons!
  # ############
  'fetch every 5 minutes emails via fetchmail':
    ensure  => absent,
    minute  => '*/5',
    command => '[ -x /usr/bin/fetchmail ] && /usr/bin/fetchmail -a >> /dev/null';
  'fetch every 5 minutes emails via fetchmail ssl':
    ensure  => absent,
    minute  => '*/5',
    command => '/usr/bin/fetchmail -a --ssl >> /dev/null';
  }
}
