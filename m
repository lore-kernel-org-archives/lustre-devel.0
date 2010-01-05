From: Eric Barton <eeb@sun.com>
Date: Tue, 05 Jan 2010 18:01:42 +0000
Subject: [Lustre-devel] SOM questions
Message-ID: <078f01ca8e31$22ff9f80$68fede80$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Vitaly,

1. Clients must replay opens on the MDS if "done writing" is still
   pending to notify the new MDS that this file is volatile.  Does it
   matter whether the client already sent "close" to the previous MDS
   instance?  Does it have to send "close" again?

2. I assume "done writing" is only sent after stripe updates have been
   committed, not just executed so that cached SOM attributes are not
   dependent on the client still being around to participate in
   recovery if an OST fails.  Is this correct?

-- 

        Cheers,
                   Eric
