From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sun, 25 Oct 2015 07:44:43 +0000
Subject: [lustre-devel] syncronous liblustreapi calls
Message-ID: <D251E3C0.113DBD%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For lctl conf_param commands, this was tricky to implement with synchronous calls, since the configuration needs to be set on the MGS (where the log is stored), but only the client (or server, depending on the parameter) knows whether that parameter is valid since the MGS won't have a mounted client for e.g. "llite" tunables, nor a mounted server for e.g. "obdfilter" tunables.  Also, there is an added complexity in whether "wait until completion" means "written to disk on the MGS" or "applied to one, some, or all clients or servers"?

I'm not saying that the current interface is good - some tests needs polling of /proc to check that conf_param parameter updates have completed.  I'm open to suggestions that solve this in a manner that doesn't allow arbitrary clients to modify global filesystem tunables...

Cheers, Andreas
--
Andreas Dilger
Lustre Software Architect
Intel High Performance Data Division

On 2015/10/22, 08:50, "lustre-devel on behalf of Ben Evans" <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org> on behalf of bevans at cray.com<mailto:bevans@cray.com>> wrote:

Is there some architectural reason behind a lack of synchronous calls to set values?

As an example, the changelog_clear operation does some preliminary checking in liblustreapi for things like non-negative ranges, and that the changelog user is formatted correctly (not that the user actually exists).

If everything checks out, it sends off an async request and tells the user everything is fine.  On the MDS, many things may go wrong (such as the range being invalid, or the user not existing), and that gets written to the logs on the MDS, but there doesn?t seem to be a way of telling the user that something went wrong.

Is there some backstory on this, or is it just an architectural consequence of the way Lustre works?

-Ben Evans
