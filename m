From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 26 May 2011 14:56:35 -0600
Subject: [Lustre-devel] LNET and IPv6?
In-Reply-To: <6EDF69A2-F4B6-49C0-A161-DE06A2529E92@gmail.com>
References: <6EDF69A2-F4B6-49C0-A161-DE06A2529E92@gmail.com>
Message-ID: <6CA65419-7663-4E11-8D66-6FAD42AF3D38@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 26, 2011, at 09:18, Nathan Rutman wrote:
> Does anyone have any ideas / plans for IPv6 support for Lustre / LNET?  Or does it remain an uninvestigated wishlist item?
> 
> This was part of the OpenSFS requirements gathering phase:
> Support for IPv6 requires a change in the NID format to accommodate a 128bit IPv6 address in the address-within-network field. This affects all protocol levels: LNDs, LNET and Lustre.

While I think there are a number of semi-interested parties, I don't think
anyone is actually working on this today.

There is a two-fold problem:
1) the less complex one is to change Lustre/LNET to handle the larger IPv6
   NIDs at compile time and get that working, but this breaks compatibility
2) the more complex one is to make an IPv6-capable Lustre work in some
   manner with older clients that don't understand it (e.g. IPv4-IPv6 LNET
   routers, different socklnds for each, or similar)

Of course, until #1 is done there is no way to know how hard #2 will be to
implement.  The earlier #1 is finished, it would be possible for many users
to upgrade to RPMs built with IPv6 support, but most of the sites that have
money to fund such work are interested in compatibility (#2) because they
cannot upgrade their entire infrastructure at one time.


Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
