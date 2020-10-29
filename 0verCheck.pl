#
use Net::DNS;
use IO::Socket;
use Getopt::Long;

GetOptions(
		"list=s"=> \$flag_list,
		"email=s"=> \$flag_email
         );



if ($flag_email) {
	@correo = split("@", $flag_email);
	$server = MX_it($correo[1]);
	print $flag_email." -- ".check($server, $flag_email)."\n";
}

if ($flag_list) {
	open(FILE, "<", $flag_list);
	@lista = <FILE>;
	close(FILE);
	foreach $account (@lista) {
		chomp($account);
		@correo = split("@", $account);
		$server = MX_it($correo[1]);
		print $account." -- ".check($server, $account)."\n";
	}
}

sub MX_it {
	$domain = $_[0];
	$resolver = Net::DNS::Resolver->new;
	@mx = mx($resolver, $domain);
	if (@mx) {
		return $mx[0]->exchange;
	} else {
		return "ERROR MX Not Found";
	}
}

sub check {
	$server = $_[0];
	$account = $_[1];
	@email = split("@", $account);
	$socket = IO::Socket::INET->new(
					PeerAddr => $server,
					PeerPort => 25,
					Proto => 'tcp'
	);

	unless ($socket) { return "ERROR";}
	
	print $socket "HELO $email[1]\r\n"; 
	$answer = <$socket>;
	print $socket "MAIL FROM: <test@".$email[1].">\r\n"; 
	$answer = <$socket>;
	print $socket "RCPT TO: <".$account.">\r\n"; 
	$answer = <$socket>;
	$answer = <$socket>;
	if ($answer =~ /250/) {
		return "OK!";
	} else {
		return "FALSE!";
	}
}
