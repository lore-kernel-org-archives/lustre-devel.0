From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 14 May 2013 00:55:05 +0000
Subject: [Lustre-devel] Interested in contributing to Lustre
In-Reply-To: <5a77f40fe7860376e5bcdfaeb8e6cb7a.squirrel@webmail.andrew.cmu.edu>
References: <5a77f40fe7860376e5bcdfaeb8e6cb7a.squirrel@webmail.andrew.cmu.edu>
Message-ID: <FFE1FEE9-EDE3-4DAC-B0F6-5AE39BEFA8C9@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2013-05-13, at 12:44, "twanjari at andrew.cmu.edu<mailto:twanjari@andrew.cmu.edu>" <twanjari at andrew.cmu.edu<mailto:twanjari@andrew.cmu.edu>> wrote:
I am a grad student at Carnegie Mellon University. I had my course work in
advanced storage systems in previous semester, and I am interested to work
on Lustre. I prefer to take up a project that could be completed in a
duration of a month or two.

Since I am a novice w.r.t. my familiarity with Lustre code base, I seek
your opinion to choose a project from the list:
http://wiki.lustre.org/index.php/Lustre_Project_List

A more up-to-date list is at:
https://wiki.hpdd.intel.com/display/PUB/Project+Ideas

My preferences (in order) are:
1. fallocate() API - https://bugzilla.lustre.org/show_bug.cgi?id=15064

This one is a bit tricky, but benefits an increasing number of users and would be the most "filesystem-y" of the listed projects. Bonus marks if you tie this in with the Lustre MPIIO-ADIO driver.

2. kernel patch removal - https://bugzilla.lustre.org/show_bug.cgi?id=21524

The main project here is to replace the "dev-read-only" patch with hooks into the "dm-flakey" driver or similar, that accepts reads, but does not write anything to disk. It is partly Lustre and partly in the kernel.

3. ioctl() number cleanups -
https://bugzilla.lustre.org/show_bug.cgi?id=20731

This would help to get Lustre into the upstream kernel, but is not necessarily going to get you distributed filesystem experience.

I am also open to other suggestion.

Any suggestions regarding code walkthrough or documentation to help
ramping up are also welcome.

Thanks,
Tejas Wanjari

_______________________________________________
Lustre-devel mailing list
Lustre-devel at lists.lustre.org<mailto:Lustre-devel@lists.lustre.org>
http://lists.lustre.org/mailman/listinfo/lustre-devel
