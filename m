From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 11 Oct 2016 14:37:53 +0300
Subject: [lustre-devel] [bug report] staging: lustre: create striped
	directory
Message-ID: <20161011113752.GA25834@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello wang di,

The patch 2de353860782: "staging: lustre: create striped directory"
from Aug 16, 2016, leads to the following static checker warning:

	drivers/staging/lustre/lustre/llite/namei.c:294 ll_md_blocking_ast()
	warn: 'master_inode' isn't an ERR_PTR

drivers/staging/lustre/lustre/llite/namei.c
   287  
   288                                  hash = cl_fid_build_ino(&lli->lli_pfid,
   289                                                          ll_need_32bit_api(ll_i2sbi(inode)));
   290  
   291                                  master_inode = ilookup5(inode->i_sb, hash,
   292                                                          ll_test_inode_by_fid,
   293                                                          (void *)&lli->lli_pfid);
   294                                  if (master_inode && !IS_ERR(master_inode)) {
                                                             ^^^^^^^^^^^^^^^^^^^^
ilookup5() never returns ERR_PTRs.

   295                                          ll_invalidate_negative_children(master_inode);
   296                                          iput(master_inode);
   297                                  }

regards,
dan carpenter
