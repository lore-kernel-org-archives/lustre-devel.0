From: Ben Evans <Ben.Evans@terascala.com>
Date: Tue, 9 Jul 2013 21:44:22 +0000
Subject: [Lustre-devel] tunefs.lustre before mount
In-Reply-To: <9234F7E5-626A-4C1A-AF02-04B23B907858@intel.com>
References: <2b233240c3104f958aeaf54f425bf265@BN1PR06MB215.namprd06.prod.outlook.com>,
	<9234F7E5-626A-4C1A-AF02-04B23B907858@intel.com>
Message-ID: <7eb8c83a97634a7dbd997ebda88989ed@BN1PR06MB215.namprd06.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ah, I was thinking more along the lines of setting the filesystem name, mgs information, peer info, etc., not things like timeouts.

-Ben Evans
________________________________________
From: Dilger, Andreas <andreas.dilger@intel.com>
Sent: Saturday, July 06, 2013 12:17 PM
To: Ben Evans
Cc: lustre-devel at lists.lustre.org
Subject: Re: [Lustre-devel] tunefs.lustre before mount

We're actually trying to get rid of tunefs.lustre for setting config parameters, since it complicates the configuration code, and only has a very limited amount of space.

That said, it should be safe to do repeatedly, though I don't think it has ever been tested.  On the flip side, lctl conf_param does have a limit on the number of parameters that can be set before the configuration has to be reset.

Cheers, Andreas

On 2013-07-05, at 14:52, "Ben Evans" <Ben.Evans at terascala.com<mailto:Ben.Evans@terascala.com>> wrote:

Assuming I can get access to all the "correct" parameters, would there be a reason that performing a tunefs.lustre before each mount would be harmful?  It's the most straightforward way I can think of to force Lustre to have the correct configuration (ib addresses, etc.) at all times.

I don't think it should be an issue, I was just wondering if anyone had run into problems repeatedly running tunefs.lustre (1000s of times against each target)

-Ben Evans
_______________________________________________
Lustre-devel mailing list
Lustre-devel at lists.lustre.org<mailto:Lustre-devel@lists.lustre.org>
http://lists.lustre.org/mailman/listinfo/lustre-devel
