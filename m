Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E1105C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 14 Feb 2022 22:09:41 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D144721F6F2;
	Mon, 14 Feb 2022 14:09:13 -0800 (PST)
Received: from na01-obe.outbound.protection.outlook.com
 (mail-centralusazon11021015.outbound.protection.outlook.com [52.101.62.15])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 200FD21F224
 for <lustre-devel@lists.lustre.org>; Mon, 14 Feb 2022 14:09:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=ep5CJ6BCSuneTuhCWXmwU1SGA8SS8z8rbC9Y8ImQ0C4U+jKpVG2q0X3pLAkXIFdOtO/HIAo7xbxYNNB6IZoxE9QQ2StTLw4EMEdB2qtIUYtCh1lwEcbbbppWIrP9bm2IEJuwcO4pL3LIDUANH8a+drDmXRwpHZ6z+ZK8ThtN5al0I3K2WWT5B59jliaey5YNj9aC4FJrA90j5a4dNia01sA4pUEwKHUkjDsb2D8ZmCPH/hdOeEKLrhySzf0cYYpCOl/PseIRKezJ/Ys/sXzMtpDGixz89vst/rzA6PIZZ9Z/jsQb4Y1NbozczbQuvtNRh79Lw4b4x5bSOw1R6JzVMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=b6HsbSyn7pbaQmQAbkarp4hFqvDyqziDVkteH4dUpEg=;
 b=EHiaKtOkNzdQm7A3RlSw5bN0itPyeE9PFynAz3Lj5Jiq2HYetPHhwsU8/wv/+eJJfUv3PHAA+LGH0gV78dcCK+TnpVAROlod/RsTmHpj07v/OL+Co+rUbVR5bSEC94cV0zulQxMzJjvyVv0k4ekvVLyu3H2eUyOc1hbMMl3phlCjXd+edZOHyNbOpqsslHRDYwL4O1/4tcNsQeLuMj5akZaAlX2D4V9oepLqw9AoZoA9iUInFNG8AlBpSsgPo6FaMxLbgOkpV3q3Nw2Ov4dIwm4Dw5n6qlh25qI7pKCtJtbmZioZQuegpftyp7KaexChXYVm+YWP0KSXvoFOhAling==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=microsoft.com; dmarc=pass action=none
 header.from=microsoft.com; dkim=pass header.d=microsoft.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=b6HsbSyn7pbaQmQAbkarp4hFqvDyqziDVkteH4dUpEg=;
 b=O89r8agvPtDVA3tJ6r0qViTpVkH0Ddz0Vm/ZmckIVh6kCSb75nRByUPYzJaapb9AaU61fU+XIKCb4Sj4Z23uEuObG7wVhamnWCva27C4qLV8Z6JCvLrUlo3acAQk1Rpt3JyS9Wd3KI8ZGwQHgsJoIaApeve2fwZEjMMZ+i6qZTE=
Received: from MN2PR21MB1439.namprd21.prod.outlook.com (2603:10b6:208:20a::15)
 by CH2PR21MB1510.namprd21.prod.outlook.com (2603:10b6:610:8e::7) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4995.8; Mon, 14 Feb
 2022 22:09:08 +0000
Received: from MN2PR21MB1439.namprd21.prod.outlook.com
 ([fe80::b041:49:3c25:f2bd]) by MN2PR21MB1439.namprd21.prod.outlook.com
 ([fe80::b041:49:3c25:f2bd%7]) with mapi id 15.20.5017.006; Mon, 14 Feb 2022
 22:09:08 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: Memory issues with bulk rpcs and buffered I/O; ptlrpc bug?
Thread-Index: AdgfhQ6qxxGIcBGwTzyTZr43wadh+wCakHNA
Date: Mon, 14 Feb 2022 22:09:07 +0000
Message-ID: <MN2PR21MB143903E11873AF9F11A01DD5BE339@MN2PR21MB1439.namprd21.prod.outlook.com>
References: <MN2PR21MB1439AD0458A0144B3825D83EBE309@MN2PR21MB1439.namprd21.prod.outlook.com>
In-Reply-To: <MN2PR21MB1439AD0458A0144B3825D83EBE309@MN2PR21MB1439.namprd21.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ActionId=f5001d4e-6071-43fd-84a9-1b5447b2ac3e;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ContentBits=0;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Enabled=true;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Method=Standard;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Name=Internal;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SetDate=2022-02-11T20:21:06Z; 
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SiteId=72f988bf-86f1-41af-91ab-2d7cd011db47;
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=microsoft.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 60946481-4bb6-4190-b6ba-08d9f0069f2c
x-ms-traffictypediagnostic: CH2PR21MB1510:EE_
x-ms-exchange-atpmessageproperties: SA|SL
x-microsoft-antispam-prvs: <CH2PR21MB15104DC5A729F0E1D8CD05ECBE339@CH2PR21MB1510.namprd21.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: KZFJ9/cZGRU60pFf2PMg3w0wZw+6G2UfJ/zqpJH8Yi9nlcvwDs8UDRciwOQK9ddh9wi2IcqQin7Jb5GZ3+60SYvM5ZNuZ0F3f2odnYK4h3BXBhIqOWaeoKOE+WyeSQGEGtaI7eGbZDt7vejdf/AsWxP8RsI4H0chbb9r3e5ot9bosvaGgbeLyZe8NVBzT1bv6hED+iRShkPZcoV/3/7kvCO5ei4FvYpz3J8XyJfSsZJmjEgqAEHDEIOv7XUkrCfrYHfjvEuqrRS0GRKYuU/kJZuIvKMAb8IQ/fNiVwRXXk1DU5Y6NUd4d5DpOzYmqM8FOl9Khwy5iL9Mc62x/MjQcTWQwEBy/yelzIhKPSKk9JfRmDikN2OUFIfpBzRmB8KEJdG3otasRWIkOA8/OGTtbZlLJpXyeuJIwDOHvDUPUXi8+FBallkvXtX5aZ7gpJDtUUlEJNb3/2qWX/6wioTdtehIV3t0GU11J5ZxQSFYfObofHSPUtG+M9qe6MdjZYRDQkgQKpA6QUQSSceHFhugRjZBr9RrWmhogJz28ntFug5il4zNJbekORIwRq8Mb7osGZNYInEGBgmLqxLX+WZg1ako57ba3ku/rTrJGl0JWGZAN4SZTh0nheybQrgB8QXqsWjMiV27WQNF89SaO+hzyGE4gAUZw6z0x741CFWn+qkizFEgSpH0TQ9RIkRj7DRsFcwUxztarVAQJiWs8g6P9mvcSb8h4TcVs8tisig1bLHOcoRBzhc5pTvPRbuQZ0DEGMjtfNwVnNsoAQmFLLoQUAG7Bp+cUL93zj8Kr832hW6PpAe9tpS4CIKE9SO5eD7TPX6ByfvAKn8y6uxmTOSujbPO1F7SxhGeJBjKaYEQE9I=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR21MB1439.namprd21.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230001)(4636009)(366004)(66556008)(8990500004)(66476007)(66446008)(66946007)(26005)(122000001)(76116006)(55016003)(8676002)(508600001)(10290500003)(8936002)(6916009)(186003)(64756008)(9686003)(38100700002)(52536014)(82950400001)(82960400001)(53546011)(966005)(7696005)(6506007)(83380400001)(2906002)(316002)(38070700005)(71200400001)(86362001)(5660300002)(33656002)(40753002);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?hroKW5+ve3MKiA8OZvPXsheASW0F0WfZJkEpSwYTGFp12DfztTfz0saSVK7Z?=
 =?us-ascii?Q?b2L2TEN66JAbKe6dXWDaoQkVaNHIKYz6rXKUqbFlMJoLJhsnjjKPWI9J6x5M?=
 =?us-ascii?Q?qrv4Q7qxTkY5lgm9/IJ9VgA0c1Y0xnPp8C1Zoi9l2rm1XvW2QkTwDemtFmLb?=
 =?us-ascii?Q?nL4Ub/GDZN8Ir0Tj64y+1QbsLMYa2d/gkkBT5fyDOteCaZM9a0W2UeZzoFZ9?=
 =?us-ascii?Q?Bay6rwKszicFFnWHDnEZbd9T5KkrSfA6Nqo5fT6VyeEltlAFJtY0qUUHVank?=
 =?us-ascii?Q?M3EfuJP/Ij/OwH+vhtXW+zhftyY5ISZVCfnN1fgUq4MO0tpv5OsS1Kiwa6Ua?=
 =?us-ascii?Q?M+7oTCscTeHX5tgLTosxd5AP3w+2SKv/Bl2GWBMDxEVJNNB50O6a49iNM27I?=
 =?us-ascii?Q?7TEb6cH69dubJ+efTe7RTP+mcgIcmPhN7tSYVSv6Vd7g+ghTY2XbdjnFAQki?=
 =?us-ascii?Q?mE3Ltv618dBVwNHVGXKp6F2ZFrmik81DBvmprTxGlsqIi+F0CVjfTn/AoG9U?=
 =?us-ascii?Q?7DX3AmUyntdUl0d5oIKocS94u71pK4Aqm/iN/HeZr0R12BiG1suChHkEtTJp?=
 =?us-ascii?Q?g5IQ4QvpIEc1BUXPNxaD9aBkkQlob5DNBkX+u98bV/M2N1V+U7ACB4Rtcgm0?=
 =?us-ascii?Q?Nzsx1AqaKKq1DQqXTDE67G71+ojjHTUxORh4QS0I6/qWmIKECdkVcsVf1Zk7?=
 =?us-ascii?Q?PVTUSTvDIC92BhjFqfXEPybYyGL/BqXcHkvOm185APJpdDIDe+nyI85zOSzQ?=
 =?us-ascii?Q?9pRRfjIBAVY60Wdhr2hNqu0G1/HxBwqW81dZUM25+qf0dpBJnWOjAOMs44ma?=
 =?us-ascii?Q?G3t5C01UiIAPj/CBh6ffWu+R3zBZK2NDvlkRJ3qKzlaF2XEacUskxKZrYmqP?=
 =?us-ascii?Q?pcbMjMmkHv8uttvXrBKXiWhjUYh7ACqjrJO15/jbdtsPyFzxx2oz6+aEZUZ7?=
 =?us-ascii?Q?kU25qk6gN/Dv+CFbdCYFjwB/Pn+G9tzR0Q9a5g8Gxzk17RDkw5iEanPIeZtY?=
 =?us-ascii?Q?g9fmT+zHDSmy/Ho4/el22Ej3RQ9CwNUa+Scf2YkuJUw8/y3Df3SNWeufgqzg?=
 =?us-ascii?Q?5kyLCGXEaMfANZQhZWm8IugFBzqZRJ0GJhwLfiJPLhDWq7c+RObijQzyiCgF?=
 =?us-ascii?Q?LD3iHMuKOPGOWVM188SlLOdUzTj5lUmAxHA6V9er7Wz1OQjHOlUPS73ZHIK6?=
 =?us-ascii?Q?QvIzJi1pPoFleEVYm+EiwtnU0cEkPNaPhthwWjjqH7bwgfkNygO1ht/n2aag?=
 =?us-ascii?Q?jkbtB/HTWaGId8MfHXgnxyYwVC5IY63T2j/qO7/3oLCKbFCjzhY3xknpK1G5?=
 =?us-ascii?Q?BOXQ6lQSyOrC8vQhwVuFuAloZK56PmGnilFs1dluhtDaurrjEy4o6JUfIr58?=
 =?us-ascii?Q?3Eo5+SmHuRYFr3k1NqavAp1qnBq4imU0VaTMUoQTUO75+63vm7ty1AHbuZlm?=
 =?us-ascii?Q?c2mf1UiPm7uYasXvAMmCmpSBJ4HEbuFUjqYkoag0Xm0Shn9/yR7WXUJLjK9j?=
 =?us-ascii?Q?4vhx2DjfOwz0zfmSgKEnuLoPk+2naqF7BENCo4zt4g+JVlV7VbHAX6eC3B0L?=
 =?us-ascii?Q?zNrGkoQJIlO3SkC0URYGSf6aGCI+J2g0lEasuYJtA9wWsIxQ078TgCbjyPwW?=
 =?us-ascii?Q?WA=3D=3D?=
MIME-Version: 1.0
X-OriginatorOrg: microsoft.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR21MB1439.namprd21.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 60946481-4bb6-4190-b6ba-08d9f0069f2c
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Feb 2022 22:09:07.9113 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 72f988bf-86f1-41af-91ab-2d7cd011db47
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: HaXVCjAuuvaglBGPGLXmNcoL/llHB0Dz7seRftp373fObWtTfIvkxKp82++dJssh2WTpoelhIoUTDfE6vnqt7bTYVoNz8Ib30QyL/DheQAM=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH2PR21MB1510
Subject: Re: [lustre-devel] Memory issues with bulk rpcs and buffered I/O;
 ptlrpc bug?
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
From: Ellis Wilson via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Ellis Wilson <elliswilson@microsoft.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

I posted what I think is root cause and a workaround in:
https://jira.whamcloud.com/browse/LU-15468

I have some resulting questions for the community, which I'll cross-post back on my original thread on lustre-discuss, since that seems to be the more active of the two channels.

If anybody thinks my RC is not accurate or has any other thoughts don't hesitate to post on that JIRA issue or ping me directly.

-----Original Message-----
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> On Behalf Of Ellis Wilson via lustre-devel
Sent: Friday, February 11, 2022 3:37 PM
To: lustre-devel@lists.lustre.org
Subject: [EXTERNAL] [lustre-devel] Memory issues with bulk rpcs and buffered I/O; ptlrpc bug?

Hi,

I'm still trying to get to the bottom of recurring OOM issues relating to: https://nam06.safelinks.protection.outlook.com/?url=https%3A%2F%2Fjira.whamcloud.com%2Fbrowse%2FLU-15468&amp;data=04%7C01%7Celliswilson%40microsoft.com%7C4a0f0c5a088847d779a908d9ed9f9c51%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C637802092058004059%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000&amp;sdata=coTYCDC8%2FQSjk5Jc3H8KHktWIqwbWw9JLKtSEUov6Vw%3D&amp;reserved=0  Any help is greatly appreciated, even if it's just "here are docs on bulk rpcs / ptlrpc / etc".

The TL;DR issue is iozone or dd can trivially drive used memory up against system limits, I/O drags to a halt due to inability to allocate new pages, and eventually all of the outstanding pages are marked cleaned and the process repeats.  Oom-killer pops in and out for longer runs.

I've been able to reproduce it on the following combinations of (kernel) + (lustre) on Ubuntu 18.04 (client-side):
5.14.11 + 2.14.0
4.15.17 + 2.14.0
4.15.17 + 2.12.8

One of the things I noticed was that when I hit the high-memory pressure condition, kswapd0 kicks in aggressively, and on-cpu graphs show that shrink_inactive_pages is cycling wildly (up to 1M calls per second).  Digging further into this, shrink_page_list is being called from that and every time it scans 32 pages, finding none available for reclaim.  This is due to the page not having a mapping (it was synced out to the OST long ago), and therefore the vmscan code is treating it almost like an anonymous page (though it's not) -- it's waiting for the last reference to drop it.  This behavior is NOT reproduced if you specify ODIRECT.

Tracing this with ftrace, I find:

If using direct I/O, kernel functions and counts per second matching 'get_page' or 'put_page' show up as (two seconds provided for each example): 

FUNC                              COUNT
pagecache_get_page                  238 
sptlrpc_enc_pool_put_pages          356 
__put_page                        45772
get_page_from_freelist            56242

FUNC                              COUNT
pagecache_get_page                  119 
sptlrpc_enc_pool_put_pages          356 
__put_page                        45693
get_page_from_freelist            55934


But if you use buffered I/O, the result is: 

FUNC                              COUNT
__put_page                        45703
pagecache_get_page               364219
get_page_from_freelist           426720

FUNC                              COUNT
__put_page                        45934
pagecache_get_page               364304
get_page_from_freelist           427555

Not only are the volumes significantly higher, but the gets to puts are way off.  Note: there are the ~55K gets per second as there were for DIO in get_page_from_freelist, PLUS one get per pagecache_get_page in get_page_from_freelist.
So, this isn't 700K newly gotten pages per second, but more like 400K newly gotten pages per second (which matches the line-rate of around 1.6GB/s), 350K of which are referenced twice and end up gunking up the inactive page lru list for vmscan.  Some time later you will see a mass put of these pages for non-DIO workloads:

FUNC                              COUNT
__put_page                      2898827

I've tracked these puts to be caused by:
   ptlrpcd_00_03-3531    [002] .... 82284.061407: __put_page: (__put_page+0x0/0x80)
   ptlrpcd_00_00-3527    [000] .... 82284.061423: __put_page: (__put_page+0x0/0x80)
   ptlrpcd_00_00-3527    [000] .... 82284.061434: <stack trace>
 => __put_page
 => ptlrpc_free_bulk
 => __ptlrpc_req_finished
 => ptlrpc_free_request
 => ptlrpc_free_committed
 => after_reply
 => ptlrpc_check_set
 => ptlrpcd_check
 => ptlrpcd
 => kthread
 => ret_from_fork

The ptlrpcd_check loop basically processes around 2M+ of these in a second and suddenly we go from 15/16GB in Used to 1/16GB in Used, the rest having returned to Free.

Anybody who can shed light on possible causes of the above behavior, provide suggested experiments or tunables to revise, or point me at useful docs on PTLRPC behavior would be greatly appreciated.

I'm baffled that PTLRPC can seemingly hold onto references to an indefinite number of pages -- despite plenty of tunables existing at higher levels to control sizes of various caches, no tunable seems to govern how many refs ptlrpc can hold onto.

Best,

ellis
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
https://nam06.safelinks.protection.outlook.com/?url=http%3A%2F%2Flists.lustre.org%2Flistinfo.cgi%2Flustre-devel-lustre.org&amp;data=04%7C01%7Celliswilson%40microsoft.com%7C4a0f0c5a088847d779a908d9ed9f9c51%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C637802092058004059%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000&amp;sdata=EpbmuiGBdhWQmJpIOSWfauDO98ciO497ptde8g6IIgI%3D&amp;reserved=0
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
