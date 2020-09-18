From: Cheremencev, Sergey <sergey.cheremencev@hpe.com>
Date: Fri, 18 Sep 2020 19:17:32 +0000
Subject: [lustre-devel] lfs usage with OST pool quota flags
In-Reply-To: <108068A0-8A57-481F-BC8B-F9F913DC3428@hpe.com>
References: <108068A0-8A57-481F-BC8B-F9F913DC3428@hpe.com>
Message-ID: <60AAD02C-7000-4364-9140-94950557B3E0@hpe.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello, Gian-Carlo DeFazio.

?The struct lquota_entry (lqe) now has 2 edquot flags,  lqe_edquot and lge_edquot.
Does lqe_edquot still represent the QMT?s current knowledge about whether or not
an entity has exceeded a quota for the pool associated with the lqe, or do the
lge_edquot flags need to be checked as well to make this determination??

I think you shouldn?t care about this if you write something for usermode utils.
But if you are interesting In details I would try to explain. Each id(user/group/project) is still described by lqe.
lqe that describes all data targets in a system is called ?global lqe?. This lqe has a pointer to array of entries that describe each OST state(lqeg_arr).
So now we can have different edquot(lge_edquot) for each target. In a system without pools all lge_edquot in array are always equal and also equal with lqe->lqe_edquot.
Each Pool Quotas has its own lqe per id. Pool Quotas lqes don?t have pointer to lqe_global_array. These lqes represent state (edquot, qunit, limits) only OSTs from the pool.
So, each id has one global lqe and one lqe per pool where it has quota limits.
When QMT get quota acquire request from an OST, it finds global lqe and ?pool? lqes(only pools that include this OST). It goes through these lqes to decide if edquot or new qunit should be set.
If yes, it also reseeds lqeg_array.

?There is now a ?pool option. Can this flag be used in conjunction with the default value flags (-U|-G|-P)??
default Pool Quotas feature is under review - https://review.whamcloud.com/#/c/39873/ (LU-13952).

If your code will interact with pool quotas, please add me as reviewer.

Thanks,
Sergey
From: "Spitz, Cory James" <cory.spitz@hpe.com>
Date: Friday, September 18, 2020 at 12:58 AM
To: "Defazio, Gian-Carlo" <defazio1@llnl.gov>, "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>, "Cheremencev, Sergey" <sergey.cheremencev@hpe.com>
Subject: Re: [lustre-devel] lfs usage with OST pool quota flags

Hello, Gian-Carlo DeFazio.

Sergey Chermencev is the developer who implemented OST Pool Quotas.  I?ve copied him so that he may answer your questions in more detail.  For now, I can say that you can use the following as resources:

https://opensfs.org/wp-content/uploads/2019/07/LUG2019-Introducing_Pool_Quotas-Spitz.pdf
https://vimeo.com/showcase/6042401/video/342817244

And yes, you can use the --pool option in conjunction with the default value flags.  See slide 11 from the referenced pdf as an example.

> Is that already happening? I see that there?s LUDOC-467 to add OST pool quotas to the manual
Yes, https://review.whamcloud.com/#/c/38414 is for it, but it hasn?t landed yet.

-Cory


On 8/31/20, 1:29 PM, "lustre-devel on behalf of Defazio, Gian-Carlo" <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org> on behalf of defazio1 at llnl.gov<mailto:defazio1@llnl.gov>> wrote:

I?m planning to add a feature to lfs-quota (a relatively quick check for EDQUOT)
and I have some questions about how the new OST pool quota feature will change things
with regards to how the quota system works internally and how the lfs-quota options will change.

For how the system actually works internally:
The struct lquota_entry (lqe) now has 2 edquot flags,  lqe_edquot and lge_edquot.
Does lqe_edquot still represent the QMT?s current knowledge about whether or not
an entity has exceeded a quota for the pool associated with the lqe, or do the
lge_edquot flags need to be checked as well to make this determination?

For how lfs-quota works:
There is now a ?pool option. Can this flag be used in conjunction with the default value flags
(-U|-G|-P)? Such as
lfs quota -U ?pool qpool1 /mnt/lustre
To check the default user quota values for OST pool qpool1?

I?ll need to update lfs-quota.1, lfs-setquota.1, and the lfs.c help section for my feature, but since
the flag I add will have to interact with the ?pool flag in some cases, I also need to update those files
for the OST pool quotas. Is that already happening? I see that there?s LUDOC-467 to add OST pool quotas to the manual.

Thanks,
Gian-Carlo DeFazio
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200918/74b4acab/attachment.html>
