From: Nic Henke <nic@cray.com>
Date: Thu, 24 Sep 2009 15:33:18 -0500
Subject: [Lustre-devel] using LST for performance testing
Message-ID: <4ABBD78E.50506@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

	I'm hoping to get a few ideas on how we could modify LST to make doing 
performance testing easier. Right now we can use "lst stat" to get a 
rough idea of performance, but the timers are pretty rough and the data 
is a snapshot.

	Any ideas ? I've got cycles to do the coding, but not sure what would 
be the best way to fit this into the existing LST framework.


BTW - the ability to dump CSV or some other text file with per-node and 
per-group data would also be nice.

Nic
