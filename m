From: Vicky White <vyw@ornl.gov>
Date: Mon, 02 Feb 2009 16:02:46 -0500
Subject: [Lustre-devel] Lustre HSM - some talking points.
In-Reply-To: <49875ABC.8000400@Sun.COM>
References: <3DF0F4AF-F4D6-476E-98F7-CD912C49FC18@Sun.COM>
	<2734A30F-2C76-4725-9F3A-29AD4245B7E8@Sun.COM>
	<496FCA67.6000500@sun.com>
	<48D329C0-242E-4A5A-94C1-DF493BB25C2F@Sun.COM>
	<496FE8D4.2090908@sun.com>
	<BEB67402-7AFE-4BE1-A59C-050823AFC8E5@Sun.COM>
	<4977647D.5010503@sun.com>
	<4977E5BD.7000706@sun.com> <4978DB1E.30507@sun.com>
	<497A144C.4000408@Sun.COM>
	<20090126193548.GF3652@webber.adilger.int> <497E35A3.3080603@sun.com>
	<DEB5E509-4641-40B6-86CA-972D885975D3@Sun.COM>
	<4983998D.1030601@sun.com>
	<8585251D-41D7-4B42-99F9-BDBFA2CF88C1@Sun.COM> <4987098F.402@Sun.COM>
	<367E32B4-A759-45AD-9D2C-48C051FE1D62@Sun.COM>
	<49872C9B.7060708@Sun.COM>
	<498734AA.7010704@ornl.gov> <4987489D.4050909@Sun.COM>
	<49874F5E.6030203@ornl.gov> <49875ABC.8000400@Sun.COM>
Message-ID: <49875F76.303@ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



> PS-The programmer's reference is close to 400 pages!  

Alas, yes.

Take two steps backward from it.   Think of chapter 2 as "posix on 
hpss", because that's basically what it is - a client api interface to 
map all the posix calls into corresponding hpss calls.   The first half 
of the chapter describes the functions and the second half the relevant 
data structures.

The other chapters are gravy - additional kinds of features you can use 
but wouldn't have to right off the bat, and some of which you'd never use.

Funny...I thought there used to be some programming examples in the 
back, but maybe that was in another book.


> Perhaps I should start with User's Guide.


I always think of that as just an explanation of the standard user 
interfaces like ftp and vfs, but you're right, it does talk about some 
hpss concepts that would be a useful intro.


Vicky
