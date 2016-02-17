From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Tue, 16 Feb 2016 17:55:52 -0800
Subject: [lustre-devel] Lustre versioning overhaul, input requested
Message-ID: <56C3D328.8080202@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello everyone,

I am hoping to make a number of build and rpm packaging improvements
early in the Lustre 2.9 development cycle.  One of the early changes, on
which a number of later changes currently depend, is an overhaul of the
method used to version Lustre.

I would love to get some more eyes on this change and get any critiques
in soon so we can get this landed potentially a week or two from now.

You can find the main jira ticket for the lustre versioning overhaul here:

https://jira.hpdd.intel.com/browse/LU-7699

The last comment in the ticket points to the current three patches
involved in the overhaul.  The first patch is the most significant of
the three in size and scope:

  http://review.whamcloud.com/18107

Change 18107 has a fairly lengthy commit comment describing the changes.

Also take a look at the file "Documentation/versioning.txt" inside of
change 18107 to see a description of how versioning works under the new
system.

Any feedback is welcome!  A lack of feedback will be interpreted as
acceptance. :)

Chris
