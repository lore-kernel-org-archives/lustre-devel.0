From: Cory Spitz <spitzcor@cray.com>
Date: Fri, 22 Mar 2019 15:59:16 +0000
Subject: [lustre-devel] git packfile
Message-ID: <30534141-20CF-43C3-BA49-0149AF7CEFE6@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

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

Thanks,
-Cory

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190322/ff59c982/attachment.html>
