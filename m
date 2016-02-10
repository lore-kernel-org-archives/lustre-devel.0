From: Jones, Peter A <peter.a.jones@intel.com>
Date: Wed, 10 Feb 2016 14:18:26 +0000
Subject: [lustre-devel] Community Release Update
Message-ID: <D2DF7987.BC02C%peter.a.jones@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi there

As Oleg shared yesterday, Lustre 2.8 Is in now in code freeze and so only blocking bugs and test script corrections are eligible to land between now and the release going GA. Getting to this point has taken much longer than targeted, largely due to the complexity in working through all the recovery edge cases when DNE is operating under load, but there are candidate fixes for the last remaining blocking bugs that are holding up well in testing and so things are looking encouraging that we are converging towards a GA release in the coming weeks.

We have been looking ahead to Lustre 2.9 for some time and expect to be able to hit the ground running with feature landings for that release as soon as next week. You can get a sense of the kind of content that might be in this release at the 2.9 wiki page - http://wiki.lustre.org/Release_2.9.0 .

You may notice that those hoping to contribute features have been required to identify who will be responsible for supporting roles like reviewing patches, writing documentation and testing. This is expected to mean more predictable delivery of complete features during the release cycle.

What is less evident due to the nature of the features likely to be ready during the appropriate time for landing for the 2.9 release is that we have now introduced a practice whereby large, potentially  disruptive, changes are segregated into a separate branch so that the whole feature can be thoroughly tested in its entirety ? and then landed in its entirety only when it is ready. There is an example of this practice in flight with the Multi-rail efforts, which may be a candidate for the 2.10 release later this year - http://review.whamcloud.com/#/q/status:open+project:fs/lustre-release+branch:multi-rail . The goal of this approach is to prevent scenarios as we have seen with DNE in this release when the inclusion of one large feature delays the whole release schedule.

I would also like to make clear that, while the release planning to date has been focused during the regular LWG meetings (http://wiki.opensfs.org/Lustre_Working_Group) that we still welcome input on the community releases from those unable to participate in those meetings.

Regards

Peter
