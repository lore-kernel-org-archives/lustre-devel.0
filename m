From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Tue, 12 Feb 2008 16:25:06 +0100
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <026801c86d67$01a0beb0$0281a8c0@ebpc>
References: <47AAE307.9040305@cea.fr> <47ACC71C.7050808@sun.com>
	<47B062BA.1070809@cea.fr> <47B0B0FF.7060805@sun.com>
	<20080212035557.GP3029@webber.adilger.int>
	<026801c86d67$01a0beb0$0281a8c0@ebpc>
Message-ID: <47B1BA52.8040304@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton a ?crit :
> Hi,
> 
> Sorry if these questions duplicates previous debate.
> 
> Have I understood correctly that the design allows individual objects
> within a lustre file (i.e. stripes?) to be purged independently?
> 
> If so why is this needed?
> 
> I would have thought that when you purge a file, you need only record
> the purged extent as an attribute of the whole lustre file and punch
> its stripes to free the space.  Am I missing a use case?


Since the beginning CFS required this feature. It seems a lab ask for 
it. I do not know who. Unfortunately we have no use case for what they 
want to do with this.
I'm wondering if their need could not be met with other features like 
the internal Lustre migration...


-- 
Aurelien Degremont
CEA
