From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Fri, 9 Mar 2012 10:48:40 -0800
Subject: [Lustre-devel] Changing FID->DLM lock encoding for version
In-Reply-To: <F36F2A9D-DFE0-43B5-8EAC-2ECEED8B21FB@whamcloud.com>
References: <F36F2A9D-DFE0-43B5-8EAC-2ECEED8B21FB@whamcloud.com>
Message-ID: <73AED5C780AE05478241DB067651A92102F1087C@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I don't think I have any problem with this -- Umka, the replicator uses the inode version, not the fid_ver, correct?


On Mar 8, 2012, at 9:56 PM, Andreas Dilger wrote:

> I'm planning to change the FID->DLM lock encoding for the FID "version" field in order to free up some space in the DLM lock resource (potentially for directory quotas, and other uses).
> 
> Currently the FID is mapped into the DLM lock as follows:
> 
>    name[0] = fid_seq(fid);
>    name[1] = fid_oid(fid);
>    name[2] = fid_ver(fid);
>    name[3] = { name hash for pdirops }
> 
> The 32-bit FID VER is currently always 0 today, and I'd like to move into the high 32 bits of name[1] along with the 32-bit OID, to avoid consuming the name[2] field. The new encoding would be equivalent to the following:
> 
>    name[0] = fid_seq(fid);
>    name[1] = ((__u64)fid_ver(fid) << 32) | fid_ver(fid);
>    name[2] = 0;
>    name[3] = { name hash for pdirops }
> 
> but using the "fid_ver_oid(fid)" macro that is also doing something similar to encode the FID into the 64-bit "o_id" and "o_gr" fields of struct obdo and elsewhere in the OST protocol.  Since fid_ver(fid) is always zero, it doesn't really matter where we encode it today, since it doesn't affect the resulting DLM lock resource name or cause any interoperability issues, but allows more flexibility in the future.
> 
> Since future use of the FID version (intended for snapshots and datasets within a single Lustre filesystem) will need changes on the client side anyway, there should never be non-zero VER seen by an older client.
> 
> A patch to do this has been submitted to Gerrit master with:
> 
> Change-Id: If1e500cfb277dfc25bc056bb0c5763e48e7dccdf
> 
> I intend to land a similar patch for b1_8 and b2_1, but I'd like to verify that nobody is using the FID version, nor plans to use it in the near future (i.e. in the next couple of years).
> 
> Cheers, Andreas
> --
> Andreas Dilger                       Whamcloud, Inc.
> Principal Lustre Engineer            http://www.whamcloud.com/
> 
> 
> 
> 
