From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 5 Nov 2015 15:57:12 +0300
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: Delete unnecessary
 checks before two function calls
In-Reply-To: <563B4878.7000106@users.sourceforge.net>
References: <alpine.DEB.2.10.1402251014170.2080@hadrien>
	<530CD2C4.4050903@users.sourceforge.net>
	<alpine.DEB.2.10.1402251840450.7035@hadrien>
	<530CF8FF.8080600@users.sourceforge.net>
	<alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	<530DD06F.4090703@users.sourceforge.net>
	<alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<563B473C.5090508@users.sourceforge.net>
	<563B4878.7000106@users.sourceforge.net>
Message-ID: <20151105125712.GV18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I don't like these patches because relying on hidden sanity checks makes
the code harder to read.

I am CC'd on all these patches because of kernel-janitors and normally I
ignore them but this is drivers/staging so I am invested in this code.
Feel free to send them to other subsystems though.

regards,
dan carpenter
