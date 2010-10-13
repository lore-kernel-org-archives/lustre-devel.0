From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Wed, 13 Oct 2010 10:51:21 +0300
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <20101013074345.GH1635@oracle.com>
References: <5A70DB00-9F04-47AF-A31C-01ADA3B87D5E@clusterstor.com>
	<AANLkTinvwRnLHaqv2-tpKpm6R2fBP51OtGR1fQCEa3KP@mail.gmail.com>
	<17D943BA-FF0B-467F-8413-CB8C8184858C@clusterstor.com>
	<AANLkTi==UJQRO+5iBKpUNfFVLWSHz4cumBApbjCz5xBe@mail.gmail.com>
	<72D9946A-6452-4BC3-8C18-D2CA607D82DC@clusterstor.com>
	<AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<B315579D-2A4F-482F-B02E-679441D4CA66@clusterstor.com>
	<20101013071201.GD1635@oracle.com>
	<49BEA69F-6931-473E-AA86-4A676A71607A@clusterstor.com>
	<20101013074345.GH1635@oracle.com>
Message-ID: <023F45A1-E881-4FD2-AF75-93324876C909@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 13, 2010, at 10:43, Nicolas Williams wrote:

> On Wed, Oct 13, 2010 at 10:27:55AM +0300, Alexey Lyashkov wrote:
>> eh.. Nicolas,
>> 
>> Format for messages which want to reconstructed after resend and don't
>> want recontructed - is different.
>> 
>> As quick example it is OPEN request (via MDS_REINT command), that type
>> message need a have extra buffer to store LOV EA, which to be send to
>> MDS in replay case (with additional flag in header).  (client have a
>> copy data from a mds reply after ptlrpc finish processing request).
>> That is why i say about "Reconstruct/replay case"
> 
> Sure, but this buffer needs to be declared a priori.  If you won't know
> whether you'll need a buffer until later, that's OK: you declare it
> anyways and you set its size to zero if you don't need it.
> 
> You can't change a capsule's format to add buffers; you can only set the
> size of unnecessary buffers to zero.  
but you can reassing format for a message :)
if you look to MDT code, you can see - for MDS_REINT you have first format 
for operation inside REINT lustre use second format

static int mdt_reint(struct mdt_thread_info *info)                                                                   
{                                                                                                                    
        long opc;                                                                                                    
        int  rc;                                                                                                     
                                                                                                                     
        static const struct req_format *reint_fmts[REINT_MAX] = {                                                    
                [REINT_SETATTR]  = &RQF_MDS_REINT_SETATTR,                                                           
                [REINT_CREATE]   = &RQF_MDS_REINT_CREATE,                                                            
                [REINT_LINK]     = &RQF_MDS_REINT_LINK,                                                              
                [REINT_UNLINK]   = &RQF_MDS_REINT_UNLINK,                                                            
                [REINT_RENAME]   = &RQF_MDS_REINT_RENAME,                                                            
                [REINT_OPEN]     = &RQF_MDS_REINT_OPEN,                                                              
                [REINT_SETXATTR] = &RQF_MDS_REINT_SETXATTR                                                           
        };

..

understand me ?


--------------------------------------
Alexey Lyashkov
alexey.lyashkov at clusterstor.com
