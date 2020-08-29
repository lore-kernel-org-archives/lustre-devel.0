From: Andreas Dilger <adilger@whamcloud.com>
Date: Sat, 29 Aug 2020 11:23:52 +0000
Subject: [lustre-devel] git packfile
In-Reply-To: <CAJ48U8Wo5tYuFzLRh-wtwtc4tt3YMKObMNx=g2LuAZc=Sv8Giw@mail.gmail.com>
References: <30534141-20CF-43C3-BA49-0149AF7CEFE6@cray.com>
 <61FFBC77-CF2E-4EDC-9060-BF9EBF7B27D0@whamcloud.com>
 <66BF972C-4BD3-4AD7-88A5-DDDF8D1CC988@amazon.com>
 <FA8580F0-1439-4901-B6E3-3E2138410675@whamcloud.com>
 <5D50C124-1325-447C-9CEB-B91646B49E5E@amazon.com>
 <7288E2CB-A8C3-4B37-AF4B-291EED278833@cray.com>
 <A29FEE1A-DEF4-4BF0-9773-743500F0E798@hpe.com>
 <764A0DD7-241A-4E72-9CAE-61048C92943F@hpe.com>
 <CAJ48U8Wo5tYuFzLRh-wtwtc4tt3YMKObMNx=g2LuAZc=Sv8Giw@mail.gmail.com>
Message-ID: <4C6FBF9F-BAAE-42C3-9662-D63267F138AB@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Aug 21, 2020, at 15:51, Shaun Tancheff <shaun at tancheff.com<mailto:shaun@tancheff.com>> wrote:

I also see this:

$ git fetch -p
remote: warning: packfile
./objects/pack/pack-ea24a680f604672cc32da7c6a91c35019c2fb7f5.pack
cannot be accessed
remote: Counting objects: 951, done.
remote: Compressing objects: 100% (274/274), done.
remote: Total 633 (delta 466), reused 479 (delta 343)
Receiving objects: 100% (633/633), 237.96 KiB | 951.00 KiB/s, done.
Resolving deltas: 100% (466/466), completed with 164 local objects.
From git://git.whamcloud.com/fs/lustre-release
  c54b6ca2bd..d7e6b6d2ab  master      -> origin/master
  95cd26446e..678772a15f  b2_12       -> origin/b2_12
+ 5ef1ba753e...c652cbd93f master-next -> origin/master-next  (forced update)
+ 3df98a6114...8f6ed5f4c5 multi-rail  -> origin/multi-rail  (forced update)

It does not appear to break my local repo but it is strange.

I've seen this a few times randomly also, but it didn't cause any problems.
Maybe newer git versions are more robust in the face of this error?

It may be a result of e.g. master-next being rewound and the old files are
removed, but I see it so rarely it is hard to debug.

Cheers, Andreas

On Thu, Aug 20, 2020 at 11:24 PM Spitz, Cory James <cory.spitz at hpe.com<mailto:cory.spitz@hpe.com>> wrote:

Hi, I'm still regularly seeing "remote: aborting due to possible repository corruption on the remote side".  Is anyone else?

I've tried multiple versions of git including recent versions.  I thought `git gc` would help, but it does not.  Is anyone else having this problem with git://git.whamcloud.com/fs/lustre-release.git ?

Thanks,
-Cory


?On 7/24/20, 4:48 PM, "lustre-devel on behalf of Spitz, Cory James" <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org> on behalf of cory.spitz at hpe.com<mailto:cory.spitz@hpe.com>> wrote:

   Hi,

   Strangely this git packfile issue has come back recently.  I was able to workaround it again by just checking out and fetching a few times.  I found this stack overflow mention about it: https://stackoverflow.com/questions/11401434/git-packfile-claims-to-have-more-objects-inaccessable  , but my local git was newer than the version mentioned there.  HPE is also having this problem for an automated checkout of git.whamcloud.com<http://git.whamcloud.com> with a much, much older git implementation, but the workaround for re-fetching git.whamcloud.com<http://git.whamcloud.com> is not working for us there.  Does anyone know more?

   I tried `git gc` in my local checkout and it seemed fine.  I'd like the automated checkout to try `git gc` too.  I'm not a git expert, do we just need to run this garbage collection on the 'remote' repo too?

   Thanks,
   -Cory

   On 3/25/19, 10:17 PM, "lustre-devel on behalf of Cory Spitz" <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org> on behalf of spitzcor at cray.com<mailto:spitzcor@cray.com>> wrote:

       I ended up checking out a few different branches and then going back to master.  At that point, the pull seemed to be OK.

       We did also experience this once in our 'official' Cray pull from upstream, but the problem went away there too after some fiddling.  I'm not sure what is making it come and go.

       Aur?lien and Andreas, thank you both for your input.  I'll keep an eye out for it and try the workaround again if it pops back up.

       -Cory

       --

       On 3/25/19, 12:22 PM, "Degremont, Aurelien" <degremoa at amazon.com<mailto:degremoa@amazon.com>> wrote:

           It depends.
           It persisted for a while. Now, I do not see them anymore. I don't know what changed in-between.


           Le 25/03/2019 11:02, ? Andreas Dilger ? <adilger at whamcloud.com<mailto:adilger@whamcloud.com>> a ?crit :

               On Mar 25, 2019, at 03:47, Degremont, Aurelien <degremoa at amazon.com<mailto:degremoa@amazon.com>> wrote:

I'm facing similar problem than Cory, times to times.
I did not track the detailed error messages but, for example, here are the errors I got when running 'git fetch' on a directory where only git://git.whamcloud.com/fs/lustre-release.git is declared. I did not update the repo for few days/weeks.

remote: warning: packfile ./objects/pack/pack-2b5d1356632dfdbfd86c2d36e529a0a8af47f9af.pack cannot be accessed
remote: error: refs/changes/47/33547/4 does not point to a valid object!
remote: warning: packfile ./objects/pack/pack-d2307b0367688a7b6599e36453a20e02d6a0302e.pack cannot be accessed
remote: error: refs/changes/47/33547/5 does not point to a valid object!
remote: warning: packfile ./objects/pack/pack-69f40cb9d10db9a97f6df59c80a6279f808b9d5d.pack cannot be accessed
remote: error: refs/changes/47/33547/6 does not point to a valid object!
remote: warning: packfile ./objects/pack/pack-090b03d5723083bb4a1e7b524bc83dc9de504f17.pack cannot be accessed
remote: error: refs/changes/47/33547/7 does not point to a valid object!
remote: warning: packfile ./objects/pack/pack-0397e40c8813c5601975c99c94afed5ddfbbf1dc.pack cannot be accessed
remote: error: refs/changes/47/33547/8 does not point to a valid object!
remote: warning: packfile ./objects/pack/pack-a20995b7160fa2708c42f05111b39126a96b9bd4.pack cannot be accessed
remote: warning: packfile ./objects/pack/pack-765a1f16499228e6910765c218733cfb8852e953.pack cannot be accessed

This problem started few months ago.

               If you do a fetch on the same tree again right away does the error persist or go away?

               Cheers, Andreas

Le 25/03/2019 07:05, ? lustre-devel au nom de Andreas Dilger ? <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org> au nom de adilger at whamcloud.com<mailto:adilger@whamcloud.com>> a ?crit :

  On Mar 22, 2019, at 09:59, Cory Spitz <spitzcor at cray.com<mailto:spitzcor@cray.com>> wrote:

Hello.

I?ve occasionally seen errors like the following when pulling upstream master:

remote: warning: packfile ./objects/pack/pack-8a0ac446942c02bf656a79a2d7fa79d33f1fa4e2.pack cannot be accessed
remote: error: refs/changes/47/5347/9 does not point to a valid object!
remote: warning: packfile ./objects/pack/pack-8a0ac446942c02bf656a79a2d7fa79d33f1fa4e2.pack cannot be accessed
remote: error: refs/changes/47/7247/23 does not point to a valid object!
remote: warning: packfile ./objects/pack/pack-8a0ac446942c02bf656a79a2d7fa79d33f1fa4e2.pack cannot be accessed
remote: error: refs/changes/47/7747/14 does not point to a valid object!
remote: warning: packfile ./objects/pack/pack-8a0ac446942c02bf656a79a2d7fa79d33f1fa4e2.pack cannot be accessed

Other clones/checkouts seem to be OK.  Has anyone else seen this?  It seems that this has something to do with Gerrit changes.  I just did a clone of master and I never set things up to my knowledge to pull all of these refs.  Anyone have a workaround (besides a fresh clone) or any tips?

  Cory, does this happen repeatedly, or just one time?  There are definitely errors that are generated because the master-next branch is "rewound" every time that Oleg lands those patches to master.

  It is a bit strange about the changes that are referenced above.  https://review.whamcloud.com/7247  and https://review.whamcloud.com/5347  were landed 5 years ago, so it is unlikely that anything related to them was changed recently.  Looking at the changes in Gerrit they appear to be OK.

  Cheers, Andreas
  ---
  Andreas Dilger
  Principal Lustre Architect
  Whamcloud







  _______________________________________________
  lustre-devel mailing list
  lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
  http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org



               Cheers, Andreas
               ---
               Andreas Dilger
               Principal Lustre Architect
               Whamcloud











       _______________________________________________
       lustre-devel mailing list
       lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
       http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

   _______________________________________________
   lustre-devel mailing list
   lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
   http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud






-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200829/9bf98f50/attachment-0001.html>
