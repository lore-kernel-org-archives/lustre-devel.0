From: Eric Barton <eeb@sun.com>
Date: Tue, 12 Feb 2008 11:04:15 +0000
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <20080212035557.GP3029@webber.adilger.int>
References: <47AAE307.9040305@cea.fr> <47ACC71C.7050808@sun.com>
	<47B062BA.1070809@cea.fr> <47B0B0FF.7060805@sun.com>
	<20080212035557.GP3029@webber.adilger.int>
Message-ID: <026801c86d67$01a0beb0$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

Sorry if these questions duplicates previous debate.

Have I understood correctly that the design allows individual objects
within a lustre file (i.e. stripes?) to be purged independently?

If so why is this needed?

I would have thought that when you purge a file, you need only record
the purged extent as an attribute of the whole lustre file and punch
its stripes to free the space.  Am I missing a use case?

-- 

        Cheers,
                Eric
