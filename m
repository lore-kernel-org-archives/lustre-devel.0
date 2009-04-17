From: Nicholas Henke <nic@cray.com>
Date: Fri, 17 Apr 2009 12:10:01 -0500
Subject: [Lustre-devel] faking LNET scale
Message-ID: <49E8B7E9.5080101@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Greetings -

	I was looking into ways to simulate scale at the LNET level. It would allow us 
to test the LNDs better with less hardware, not to mention things like LNet 
SelfTest and friends.

	With the work in bug 15332 to add multiple nets per NIC, it seemed fairly close 
that we could use that to generate multiple LND connections from a single NIC. 
Ideally we'd have a server or router that would have just one LND instance 
(ptl0) and the client nodes with multiple interfaces (ptl1, ptl2, ...). This 
would increase the load on those server nodes to something interesting.

However, to do this either hacking up lnet_ptlcompat_matchXXX to look at another 
flag besides the_lnet.ln_ptlcompat or some other way of allowing a server with a 
single NET (ptl0) to accept requests from a variety of nets (ptl1, ptl2, etc). 
One cannot use multiple interfaces for the same net type with ln_ptlcompat enabled.

	Is there a better way to do this ? What would be the least abusive of th e rules ?

Cheers,
Nic
