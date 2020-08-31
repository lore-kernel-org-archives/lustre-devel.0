From: Defazio, Gian-Carlo <defazio1@llnl.gov>
Date: Mon, 31 Aug 2020 18:28:50 +0000
Subject: [lustre-devel] lfs usage with OST pool quota flags
Message-ID: <BY5PR09MB54906EEA222E2AF6D6505F69E3510@BY5PR09MB5490.namprd09.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'm planning to add a feature to lfs-quota (a relatively quick check for EDQUOT)
and I have some questions about how the new OST pool quota feature will change things
with regards to how the quota system works internally and how the lfs-quota options will change.

For how the system actually works internally:
The struct lquota_entry (lqe) now has 2 edquot flags,  lqe_edquot and lge_edquot.
Does lqe_edquot still represent the QMT's current knowledge about whether or not
an entity has exceeded a quota for the pool associated with the lqe, or do the
lge_edquot flags need to be checked as well to make this determination?

For how lfs-quota works:
There is now a -pool option. Can this flag be used in conjunction with the default value flags
(-U|-G|-P)? Such as
lfs quota -U -pool qpool1 /mnt/lustre
To check the default user quota values for OST pool qpool1?

I'll need to update lfs-quota.1, lfs-setquota.1, and the lfs.c help section for my feature, but since
the flag I add will have to interact with the -pool flag in some cases, I also need to update those files
for the OST pool quotas. Is that already happening? I see that there's LUDOC-467 to add OST pool quotas to the manual.

Thanks,
Gian-Carlo DeFazio
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200831/b8dee453/attachment-0001.html>
