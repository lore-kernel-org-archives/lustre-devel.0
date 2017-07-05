From: Dmitriy Cherkasov <dmitriy@oss-tech.org>
Date: Wed, 5 Jul 2017 22:03:21 +0000
Subject: [lustre-devel] Dead code cleanup
Message-ID: <2d7d67d4-3716-c521-e7dd-b8f934330c7e@oss-tech.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Folks,

I've found one last #if 0 block in the code, but when attempting to investigate 
its origin I ran into a dead end.

The code in question [1] has not been touched since 2013 [2], and seems to 
originate from one big patch [3] with a non-public commit history. I found the 
relevant bugzilla entry [4], but no history beyond that.

Although I was unable to find the original intent behind it, I think it's safe 
to assume it is not used and if there are no objections I'll post a patch to 
remove it.

Thanks,
Dmitriy

[1] 
https://git.hpdd.intel.com/?p=fs/lustre-release.git;a=blob;f=lustre/lov/lov_io.c;h=2339ea56;hb=HEAD#l1067
[2] https://git.hpdd.intel.com/?p=fs/lustre-release.git;a=commit;h=d2589286
[3] https://git.hpdd.intel.com/?p=fs/lustre-release.git;a=commit;h=fbf5870b
[4] https://projectlava.xyratex.com/show_bug.cgi?id=14166
