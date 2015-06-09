From: Patrick Farrell <paf@cray.com>
Date: Tue, 9 Jun 2015 15:30:26 -0500
Subject: [lustre-devel] OBD_CONNECT_* flags
Message-ID: <55774CE2.30107@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Good afternoon,

Hopefully a fairly quick question...  I'm adding a new feature (lock 
ahead) and would like to use an OBD_CONNECT flag to verify it's 
supported on the server.  I took a quick stab at adding one, but I'm 
getting lost in the details of how the flags are set and exchanged.

Essentially, I would like the client and server (OSS in this case) to 
both have a particular OBD_CONNECT flag or the client will return 
-EOPNOTSUPP when the feature (an ioctl) is invoked.
So: Is an OBD_CONNECT flag the right way to do this?
If so, could anyone give a brief explanation of how that works, or an 
example to build off of?

Thanks,
- Patrick Farrell
