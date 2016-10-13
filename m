From: James Simmons <jsimmons@infradead.org>
Date: Thu, 13 Oct 2016 23:38:01 +0100 (BST)
Subject: [lustre-devel] [bug report] staging: lustre: create striped
	directory
In-Reply-To: <20161012091755.GD5687@mwanda>
References: <20161011113752.GA25834@mwanda> <D4225DB9.44EC%di.wang@intel.com>
	<20161012091755.GD5687@mwanda>
Message-ID: <alpine.LFD.2.20.1610132336130.18218@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Tue, Oct 11, 2016 at 04:14:11PM +0000, Wang, Di wrote:
> > Hello,
> > 
> > On 10/11/16, 4:37 AM, "Dan Carpenter" <dan.carpenter@oracle.com> wrote:
> > 
> > >Hello wang di,
> > >
> > >The patch 2de353860782: "staging: lustre: create striped directory"
> > >from Aug 16, 2016, leads to the following static checker warning:
> > >
> > >	drivers/staging/lustre/lustre/llite/namei.c:294 ll_md_blocking_ast()
> > >	warn: 'master_inode' isn't an ERR_PTR
> > >
> > >drivers/staging/lustre/lustre/llite/namei.c
> > >   287  
> > >   288                                  hash =
> > >cl_fid_build_ino(&lli->lli_pfid,
> > >   289            
> > >ll_need_32bit_api(ll_i2sbi(inode)));
> > >   290  
> > >   291                                  master_inode =
> > >ilookup5(inode->i_sb, hash,
> > >   292            
> > >ll_test_inode_by_fid,
> > >   293                                                          (void
> > >*)&lli->lli_pfid);
> > >   294                                  if (master_inode &&
> > >!IS_ERR(master_inode)) {
> > >                  
> > >^^^^^^^^^^^^^^^^^^^^
> > >ilookup5() never returns ERR_PTRs.
> > 
> > Yes, only master_inode != NULL should be enough here.
> 
> Please send a patch to remove the other check?

A patch is being reviewed and validated with our test harness.
Its coming :-)
