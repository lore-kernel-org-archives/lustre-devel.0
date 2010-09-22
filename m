From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Wed, 22 Sep 2010 11:28:00 -0700
Subject: [Lustre-devel] Lustre RPC visualization
In-Reply-To: <1285163194.2244.416.camel@radar>
References: <000c01cae6ee$1d4693d0$57d3bb70$%barton@oracle.com>
	<4BD8E021.7050302@oracle.com> <4BD90FB9.5030702@tu-dresden.de>
	<4BD9CF75.8030204@oracle.com> <4BDE8C3C.2050505@tu-dresden.de>
	<699F57EF-52E6-41D1-A04B-3C39D469D133@oracle.com>
	<4BDF1199.2030007@tu-dresden.de> <4BDF1CC7.5020502@oracle.com>
	<4BDF24BC.9050701@tu-dresden.de> <4BDF2999.2000207@oracle.com>
	<4BEFBB07.4030403@tu-dresden.de>
	<1274788995.2261.110.camel@radar> <4BFC7177.9000808@oracle.com>
	<1275058473.21591.14.camel@radar> <4BFFA456.7030502@oracle.com>
	<C671351E-110C-4D2C-B216-4E8BE23A943A@oracle.com>
	<1285163194.2244.416.camel@radar>
Message-ID: <A45FCE0C-FD73-4F87-B080-72EB276B9488@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-09-22, at 06:46, Michael Kluge wrote:
> could please sent me the command how to generate such a log? 
> 
> lctl debug_daemon start /tmp/$HOSTNAME
> sysctl -w lnet.debug=+rpctrace
> 
> Still produces some kind of binary format (at least with my 1.8.3) which
> looks different from what you sent me.

There are a few different ways to generate a Lustre debug log:
- "lctl dk [filename]" (short for "lctl debug_kernel [filename]") will
  dump the current debug buffer to [filename], or stdout if unspecified.
  It will decode the binary debug log into ASCII at this time
- "lctl debug_daemon {filename}" starts the binary kernel debug log to be
  written to {filename} as the debug pages are filled
- in case of LBUG/LASSERT it also dumps the binary debug log to the file
  /tmp/lustre.log.{timestamp} (unless specified otherwise)

In the last two cases, it is necessary to run "lctl debug_file {infile} [outfile]" decodes binary the input file to the ASCII output file.  This should preferably be run on the system where the binary file was generated, though generally the binary format is only changing between systems of different endianness.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
