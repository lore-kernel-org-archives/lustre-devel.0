From: kbuild test robot <lkp@intel.com>
Date: Wed, 14 Oct 2015 07:25:06 +0800
Subject: [lustre-devel] [PATCH 2/7] staging: lustre: llite_nfs.c:
 replace container_of0 by container_of
In-Reply-To: <a9b823b1753239156b310ecb9ac109023629bc23.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <201510140754.x1M8HsOi%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Aya,

[auto build test WARNING on staging/staging-next -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Aya-Mahfouz/staging-lustre-remove-uses-and-definition-of-container_of0/20151014-062751
config: blackfin-allmodconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=blackfin 

All warnings (new ones prefixed by >>):

   drivers/staging/lustre/lustre/llite/llite_nfs.c: In function 'll_nfs_get_name_filldir':
>> drivers/staging/lustre/lustre/llite/llite_nfs.c:213:26: warning: initialization from incompatible pointer type [enabled by default]
>> drivers/staging/lustre/lustre/llite/llite_nfs.c:213:26: warning: (near initialization for 'lde') [enabled by default]

vim +213 drivers/staging/lustre/lustre/llite/llite_nfs.c

   197		if (*plen < sizeof(struct lustre_nfs_fid) / 4)
   198			return 255;
   199	
   200		nfs_fid->lnf_child = *ll_inode2fid(inode);
   201		nfs_fid->lnf_parent = *ll_inode2fid(parent);
   202		*plen = sizeof(struct lustre_nfs_fid) / 4;
   203	
   204		return LUSTRE_NFS_FID;
   205	}
   206	
   207	static int ll_nfs_get_name_filldir(struct dir_context *ctx, const char *name,
   208					   int namelen, loff_t hash, u64 ino,
   209					   unsigned type)
   210	{
   211		/* It is hack to access lde_fid for comparison with lgd_fid.
   212		 * So the input 'name' must be part of the 'lu_dirent'. */
 > 213		struct lu_dirent *lde = container_of(name, struct lu_dirent, lde_name);
   214		struct ll_getname_data *lgd =
   215			container_of(ctx, struct ll_getname_data, ctx);
   216		struct lu_fid fid;
   217	
   218		fid_le_to_cpu(&fid, &lde->lde_fid);
   219		if (lu_fid_eq(&fid, &lgd->lgd_fid)) {
   220			memcpy(lgd->lgd_name, name, namelen);
   221			lgd->lgd_name[namelen] = 0;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 38047 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151014/b9f371b1/attachment-0001.obj>
