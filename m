From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Mar 2019 04:50:58 +0000
Subject: [lustre-devel] git packfile
In-Reply-To: <30534141-20CF-43C3-BA49-0149AF7CEFE6@cray.com>
References: <30534141-20CF-43C3-BA49-0149AF7CEFE6@cray.com>
Message-ID: <61FFBC77-CF2E-4EDC-9060-BF9EBF7B27D0@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 22, 2019, at 09:59, Cory Spitz <spitzcor@cray.com> wrote:
> 
> Hello.
>  
> I?ve occasionally seen errors like the following when pulling upstream master:
>  
> remote: warning: packfile ./objects/pack/pack-8a0ac446942c02bf656a79a2d7fa79d33f1fa4e2.pack cannot be accessed        
> remote: error: refs/changes/47/5347/9 does not point to a valid object!        
> remote: warning: packfile ./objects/pack/pack-8a0ac446942c02bf656a79a2d7fa79d33f1fa4e2.pack cannot be accessed        
> remote: error: refs/changes/47/7247/23 does not point to a valid object!        
> remote: warning: packfile ./objects/pack/pack-8a0ac446942c02bf656a79a2d7fa79d33f1fa4e2.pack cannot be accessed        
> remote: error: refs/changes/47/7747/14 does not point to a valid object!        
> remote: warning: packfile ./objects/pack/pack-8a0ac446942c02bf656a79a2d7fa79d33f1fa4e2.pack cannot be accessed     
>  
> Other clones/checkouts seem to be OK.  Has anyone else seen this?  It seems that this has something to do with Gerrit changes.  I just did a clone of master and I never set things up to my knowledge to pull all of these refs.  Anyone have a workaround (besides a fresh clone) or any tips?

Cory, does this happen repeatedly, or just one time?  There are definitely errors that are generated because the master-next branch is "rewound" every time that Oleg lands those patches to master.

It is a bit strange about the changes that are referenced above.  https://review.whamcloud.com/7247 and https://review.whamcloud.com/5347 were landed 5 years ago, so it is unlikely that anything related to them was changed recently.  Looking at the changes in Gerrit they appear to be OK.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
