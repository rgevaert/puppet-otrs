# --
# Kernel/System/Auth/casAuth.pm - provides CAS authentication
# --
# UGent 2011, Gert Schepens
#
# Requires AuthCAS 
#  http://search.cpan.org/~osalaun/AuthCAS-1.5/lib/AuthCAS.pm
#
# Installeren in de otrs ./Custom/Kernel/System/Auth/ directory
# en configureren in de ./Kernel/Config.pm settings file:
# $Self->{'AuthModule'} = 'Kernel::System::Auth::casAuth';
#
# Geen / op het einde!! bij AuthModule::casAuth::CASurl
#
# $Self->{'AuthModule::casAuth::CASurl'} = 'https://login.ugent.be';
# Optioneel: CAfile - In geval van niet officieel cert veronderstel ik?
# $Self->{'AuthModule::casAuth::CAfile'} = '/var/local/apache_1.3.31/conf/ssl.crt/ca-bundle.crt';
#
# Updates
#  1.3 Test versie! misc bug fixes ("no userdata found for 1" error, debugging functionaliteit; debugging default aan)
# --

package Kernel::System::Auth::casAuth;

use strict;
use AuthCAS;

use vars qw($VERSION %Env);
$VERSION = '1.3';

sub new {
    my $Type  = shift;
    my %Param = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    foreach (qw(LogObject ConfigObject DBObject)) {
        $Self->{$_} = $Param{$_} || die "No $_!";
    }

    # Debug 0=off 1=on
    $Self->{Debug} = 1;

    # Check of er een CASurl is
    $Self->{CASurl} = $Self->{ConfigObject}->Get('AuthModule::casAuth::CASurl')
      || die
      "casAUTH requires AuthModule::casAuth::CASurl in Kernel/Config.pm!";

    # Check of er een CAfile is
    $Self->{CAfile} = $Self->{ConfigObject}->Get('AuthModule::casAuth::CAfile')
      || undef;

    # Maak het CAS object aan
    my $CASobject;
    if ( defined $Self->{CAfile} ) {
        $CASobject = new AuthCAS(
            'casUrl' => $Self->{CASurl},
            'CAFile' => $Self->{CAfile},
        );
    }
    else {
        $CASobject = new AuthCAS( 'casUrl' => $Self->{CASurl}, );
    }
    $Self->{CASobject} = $CASobject;

    # pas de login url aan zodat cas zijn werk kan doen
    $Self->{'ConfigObject'}->{LoginURL} =
      '/' . $Self->{'ConfigObject'}->{'ScriptAlias'} . 'index.pl?Action=Login&';

    # ThisURL , the URL cas posts back to.
    $Self->{ThisURL} =
      $Self->{'ConfigObject'}->{'HttpType'} . "://" .  # Support for http/https
      $Self->{'ConfigObject'}->{'FQDN'} .              # FQDN; otrsdev1.ugent.be
      $Self->{'ConfigObject'}->{LoginURL};             # login URL

    return $Self;
}

sub GetOption {
    my $Self  = shift;
    my %Param = @_;

    # check needed stuff
    if ( !$Param{What} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => "Need What!" );
        return;
    }

    # module options
    my %Option = ( PreAuth => 0, );

    # return option
    return $Option{ $Param{What} };
}

 # $Self->{LogObject}->Log( Priority => 'notice', Message => "Debug: " ) if ( $Self->{Debug} );
sub Auth {
    my $Self  = shift;
$Self->{LogObject}->Log( Priority => 'notice', Message => "Debug: Auth started" ) if ( $Self->{Debug} );
    my %Param = @_;

# if debug; zeg auth gestart en print %Param
if ( $Self->{Debug} ) {
  $Self->{LogObject}->Log( Priority => 'notice', Message => "Debug %Param: ". %Param );
    my $ParamList;
    foreach $a (%Param) {
      $ParamList .= "'". $a . "' ";
    }
  $Self->{LogObject}->Log( Priority => 'notice', Message => "Debug %Param: ". $ParamList );
}


    # Deze site url
    my $ThisURL = $Self->{ThisURL};

    # authCAS object
    my $CASobject = $Self->{CASobject};

    # CGI object
    my $CGI = new CGI; 
# if debug; print CGI param
if ( $Self->{Debug} ) {
  $Self->{LogObject}->Log( Priority => 'notice', Message => "Debug: CGI: ". $CGI->param );
  foreach $a ($CGI->param) {
    $Self->{LogObject}->Log( Priority => 'notice', Message => "Debug: CGI ".$a.": ". $CGI->param($a) );
  }
}

    # Als OTRS een reason terug geeft, stop en meld aan de gebruiker
    my $Reason = $CGI->param('Reason') . $CGI->param('?Reason');
    if ( $Reason ) {
        my $ReasonError =
          "CAS auth: OTRS authentication error: " . $Reason;
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message  => $ReasonError,
        );
        die $ReasonError unless ( $Reason =~ /InvalidSessionID/ ) ;
    }

    # Haal de ticket uit de parameters
    my $GivenServiceTicket = $CGI->param('ticket');

    # Check of er een Service Ticket is
    if ( defined $GivenServiceTicket ) {

        $ThisURL = $Self->{ThisURL};

        # Valideer het ST
        my $UserID = $CASobject->validateST( $ThisURL, $GivenServiceTicket );
# if debug; CASobject returned $UserID
$Self->{LogObject}->Log( Priority => 'notice', Message => "Debug: CASobject UserID: ". $UserID ) if ( $Self->{Debug} );

        # Als de ST een user opleverde is de gebruiker ingelogged
        if ( defined $UserID ) {
            $Self->{LogoutURL} = $CASobject->getServerLogoutURL($ThisURL);
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message  => "CAS auth: $UserID authentication ok.",
            );
            return $UserID;

            # Anders is de authenticatie gefaald
        }
        else {
            my $error =
              "CAS auth: authentication failed: " . &AuthCAS::get_errors();
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message  => $error,
            );
            return;
        }

    }

    # Als er geen ST is moet er een gehaald worden via onderstaande URL
    else {
        my $url = $CASobject->getServerLoginURL( $Self->{ThisURL} );
        my $error =
"CAS auth: No CAS ticket. Probably a new login; redirecting to CAS at $url";
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message  => $error,
        );
        print "Location: $url\n\n";
    }

return;
}

1;    # Because perl likes a Happy Ending

