From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Mon, 19 Aug 2013 18:01:39 -0700
Subject: [Lustre-devel] Community Roadmap Update, Realignment on 2.5
In-Reply-To: <520C10E3.7030405@llnl.gov>
References: <520C10E3.7030405@llnl.gov>
Message-ID: <5212BFF3.7000002@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Background
----------

The Lustre community has banded together to work on the development of 
the Lustre source code.  As part of that effort, we regularly discuss 
the roadmap for major Lustre releases.  We have developed a schedule of 
major releases that occur every six months.

We recognize, however, that many organizations need a branch of Lustre 
that they can run for much longer periods of time than six months.  To 
that end we collectively decided that we would target the Lustre 2.4.0 
feature release to begin a side branch of Lustre to receive regularly 
scheduled maintenance releases for a significant period of time (18 
months or more).

Unfortunately, one particular feature that some folks feel strongly is 
an absolute requirement, HSM (Hierarchical Storage Management), did not 
land on the development branch in time for Lustre 2.4.0.  Happily HSM is 
now landed on the master branch, and will appear in the next Lustre 
feature release, version 2.5.0.

Rather than split the community effort between two closely spaced 
scheduled maintenance release branches, we have decided to realign our 
efforts from the 2.4 branch to the 2.5 branch.

An updated Community Lustre Roadmap has been posted here:

   http://lustre.opensfs.org/community-lustre-roadmap/

What this means in a Nutshell
-----------------------------

The Lustre 2.5 branch is the one for which we expect to see regularly 
scheduled maintenance releases for an extended period of time (18+ months).

We no longer expect regularly scheduled maintenance releases on the 
Lustre 2.4 branch after the Lustre 2.4.2 release.  Our recommended 
upgrade path after 2.4.2 is an upgrade to the latest 2.5.X release.

What to do if you are already committed to Lustre 2.4
-----------------------------------------------------

If you have already committed to using Lustre 2.4 at your organization 
and an upgrade to Lustre 2.5 is not either desired or possible, we 
recommend that you contact your Lustre support vendor to find out which 
branches they intend to support.  Some Lustre vendors offer support for 
branches beyond the Community's officially recommended releases.

Some Lustre vendors have already announced their intent to continue 
supporting their users who have committed to the Lustre 2.4 branch.

Chris Morrone
OpenSFS Community Development Working Group Lead
