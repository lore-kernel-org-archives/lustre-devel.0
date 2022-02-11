Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EE072C433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 11 Feb 2022 20:46:41 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7D39C3B8F7B;
	Fri, 11 Feb 2022 12:37:06 -0800 (PST)
Received: from na01-obe.outbound.protection.outlook.com
 (mail-centralusazon11021025.outbound.protection.outlook.com [52.101.62.25])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B41C03B8F6D
 for <lustre-devel@lists.lustre.org>; Fri, 11 Feb 2022 12:37:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Toc7ogQemWJ9ZW5HbYyGBfUY7V87qA28TVd8ROCuk8hr4aV6ku6lhJ6K1ttQmFcp6NZBSAc9s+4NG5UkqsF5odI+tcqdYfJ0bB1+yOWvvqvDGjbup03KqcDJVz92+QijqFA07zEsoRojwGBuiVKU5azkWf2nKd1KTk0MFg7oAoMAJUkWPRMcBEsnLjbnd1VF4ofHFvZ1hT2aVgKrtclQ7kUCGp41zZ0QpuIM9zbk9oAj3IwxAtxerKokYCqvYMrRyYSU7PWPnTuRfAsmvbpFk721+nTHzQIJ6kjLh3BnCeKFilQEylAknPeGCQWJP/9p7L3JhuRGls1W6Q5TfU7nCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=KkPoSbPlKQiSe4l27n/x1IMCVVoZ51quETYuwOFwG3w=;
 b=HbPSeeYpBrbJ/24el0oWoDyHHuY1DEOHwEc07GMi5ivn3GYr0ODA36oidB3CofAQawsiHWapu+gNDDPxMxGK7+SQN4uQ+4N8KN3hxYJzr+7ZVddvOeLbkB5zTOwPwjJkKf8SvZc7/OaTG5Kq5GkBFxiK05cE/ZHCK3Nz82ECuPYQSF1bi12q4I0RDrl9WnCnnw5z6p09mHtJM5BHQfvMDeefnitVnokgLlzv6gjHUJWlbF94zUuieMd9OIGk5s60Hi4QGME6Eces7xfY/SQkjXHVGBmafrLO1SE48zE5KaD11b3QPbRqslBE715n8OHaS01/fCWvrwK/5SrlaGt4LQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=microsoft.com; dmarc=pass action=none
 header.from=microsoft.com; dkim=pass header.d=microsoft.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=KkPoSbPlKQiSe4l27n/x1IMCVVoZ51quETYuwOFwG3w=;
 b=aWUWrXxPYnexIDPh0LFiKf7mEiSV66c0RoTBfKYR0PNhfGyOcOXYcxZqmR9envD1cNkIRKPahkVx6jcxXLzwTtwlDpDfx0ENhzwRTgUuqbVVTjK/on4ZwY0uRGUiqEmDgYQrcTnSK3zmMjMakXeXIvdoB1jZ18w5aylxN0oMdho=
Received: from MN2PR21MB1439.namprd21.prod.outlook.com (2603:10b6:208:20a::15)
 by BN6PR21MB0467.namprd21.prod.outlook.com (2603:10b6:404:b2::17)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4995.6; Fri, 11 Feb
 2022 20:37:00 +0000
Received: from MN2PR21MB1439.namprd21.prod.outlook.com
 ([fe80::9536:319b:96cb:6f6d]) by MN2PR21MB1439.namprd21.prod.outlook.com
 ([fe80::9536:319b:96cb:6f6d%4]) with mapi id 15.20.4995.004; Fri, 11 Feb 2022
 20:37:00 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: Memory issues with bulk rpcs and buffered I/O; ptlrpc bug?
Thread-Index: AdgfhQ6qxxGIcBGwTzyTZr43wadh+w==
Date: Fri, 11 Feb 2022 20:37:00 +0000
Message-ID: <MN2PR21MB1439AD0458A0144B3825D83EBE309@MN2PR21MB1439.namprd21.prod.outlook.com>
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
x-ms-office365-filtering-correlation-id: e72eebf9-00f2-489e-7952-08d9ed9e4153
x-ms-traffictypediagnostic: BN6PR21MB0467:EE_
x-ms-exchange-atpmessageproperties: SA|SL
x-microsoft-antispam-prvs: <BN6PR21MB04675F3A795724BB71470F90BE309@BN6PR21MB0467.namprd21.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: z+ZPtyyZhMs/9+TjxLhhZFxJre0Ea1fwM47aFgNfltJUdmroJPCSlcK0IYG0VxqMcwW594Cg9IR7w8bLMpbgDXDZJNKIDA5SIMG2V3BaC2r4P6fIxfuRX4BAOxJwGcZlwgyA4DuujUygbh8alYVmtVBS8HsJZMh5DlAqAF8hKFO/0FPMpCOlx8pnwHM+ZfrwHUDHWgGrBG3RPuaGlQ1SIOhR+vDr2Q2trHQr56yzw2MLcKKvfePL4+a1MuvmrLoEB92iP5Of40ai4w+GIkPQY/0cUPgja8xoMH5JialBTcYnS7dc8iBlHxCwbEaZJtTBL4nVrm8tx+6oOfzH+83ka8iFtsgVFd6AnBQYgYnHByhN3C3Hdcgft8e31K0i9qx6jGK9rd/u720rmAMMkTQ0+A7RrwFvZhb9NX8v+UM6tcWvXhChuM3nONQK0VZQw5obP/laE57GbKeRAk79rpkvfH9Ii7BpU5ahPPshQJnqJ19LgwsiBxbRb8BpuRVN+6EUoiYJznjiDylIZXTALNX8HA9SXuzWrhE/7+dLPYu6G4c/96L6dVaEYkCzcw6HSq1el9ch4SF58XYlfICRNTabwRktChS3ATBkhu9jUiTdhcZlWhCI6vwqKJ0Q8KJl652oieOYC7VIiHNnJNoLcHFwKCJZlpbHhuop4eESCrb4ebZWgO7VvZRR3fjT6SObMHO82eNTYJyLM5iTLzx8kjCu8LdeQdyJOxc55+RmtFHKH2QmTSTQIN/fQV+wTUB+vC5sNi958o+YXmQVtG//QTlpJq3QM2ng4OEzk8wv15Vrgv5U+MJBnQm0X+C0JOKoAjWKrBD5Zn95QIde/rbruGLAqVTBB6FuSXICLOVrgCh1VyU=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR21MB1439.namprd21.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230001)(4636009)(366004)(82960400001)(122000001)(71200400001)(64756008)(82950400001)(66556008)(66476007)(66946007)(8990500004)(6506007)(55016003)(38100700002)(7696005)(52536014)(33656002)(8936002)(316002)(76116006)(66446008)(9686003)(186003)(6916009)(38070700005)(83380400001)(2906002)(5660300002)(508600001)(86362001)(8676002)(26005)(10290500003)(966005)(40753002);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?NSe+C4ALGDwYgB3vppRshGTSooHOTHKtAM0NBCo7puZHHQ0QjJ6U+PJ13T/+?=
 =?us-ascii?Q?FoN71Bd5vEV78lip+Ce3ZZtLmxvv2y3EOrdxLCp2KjGKIcVUnlnxS+dcj0Z6?=
 =?us-ascii?Q?vVlVbuWfsEnbsQ9vqcCVOvFQQEuwAW+4ubjsAvILVbdMIhQKM9qqVft8Ujlo?=
 =?us-ascii?Q?SVARdLC7ne0iVLob74nR/g78dAToOi+f9n1qwwObjtcvlmynkCmkbkOyu6gx?=
 =?us-ascii?Q?IOy3jthdfCZeHU5MyimyRBQRxw1tPEpkSrOKFzgxffT1HhmEIo5weVFF/Sbw?=
 =?us-ascii?Q?l/YnTkxL5I9U4fYpBbMWWkSmNqkizv/mDSvP6TpfatYIpvgYEKJWxELwzVQM?=
 =?us-ascii?Q?9HjnJaV6WAehWGCZkP5Pmaqua3PCHfSVmiHwNpj72zbw2o5/KdiYbyoTE523?=
 =?us-ascii?Q?GLYt1mPPDZw6OMwqiu3QHl9LHUX8mEDbb1oQsd8upELTvONgTMauS4GcaXgA?=
 =?us-ascii?Q?WqnAU3qOk9nVpTANli66xk3N0jXxv/zhK4h/IG7BStZ/z2C4eD1wmCGiqB9d?=
 =?us-ascii?Q?GXqpCXC/hQORCqe6dHETWHuogftJnYTw2e0bkx5bwqccqrcDq+yPwNIB9MaR?=
 =?us-ascii?Q?N9fSWFiF1xCD3dYc204fGmgTJB2ICbcH9dh4JvDaBQW/ZNlglXWsaiOqu2a6?=
 =?us-ascii?Q?eDJUfZGcR+rjHM4umz6e8BQROKpAY5uwm+gTHOvJZIyjzDr+yFYGM+uJdmOy?=
 =?us-ascii?Q?Qkx8HsjbSZQyCdLNFP945NpYUHBw066NbpAwz/EWh24PS8EQoV3dPWG4oerK?=
 =?us-ascii?Q?mnEajN4IwXbi8dfZrUWJWANw9PhxlHcOFOJqUIm7VhQ3TR863lLkHhbXKaL1?=
 =?us-ascii?Q?4QKNE8vZlCZaxkYdmgRgQbr5fKLfEj0Iy/NFMBcLCLhyo2z9Y91zZeTx1bDm?=
 =?us-ascii?Q?6amiQ1UWPiV/7tG/VlvKOtZ5Jz61W615lOE22XQM8169Jxu1KeCPiapCJ4Jw?=
 =?us-ascii?Q?beAVkBZfJGBpp37or9xELKa4XT2qn8Cwz1FEM2LEnoqbrzO29R0fJsgUV2Q/?=
 =?us-ascii?Q?9wLBHV98RgWm/AeRnwpE3NNOUxs78SH52vbhFoxStz164gVnJFQM2ZxBGP3N?=
 =?us-ascii?Q?T4oS27IRRvszAUw7N2dxhx93+vhGOZZeKqHggRxnhQRfi4gjv1KpkPAoX9NP?=
 =?us-ascii?Q?08wjJDdiU6EpIbKEKF6dGI6yqIvhwtqXF/d1Xwd+YCFy7w9hxz3mpZCykqDy?=
 =?us-ascii?Q?xCH8fXfs+ClL18NZH1+P+/U+t3kJzvH5AB9OXGT7PztKDGisAxoJy4ucH74C?=
 =?us-ascii?Q?AA+T0F6KAVJ/+d9NsB/i8GU3w0miqEjqTwkmSyFmKJHl3LCppEJWKisA84YH?=
 =?us-ascii?Q?pbJpDY5uO2pWf1bFYtvRV0MAM4/LgWue0VZ2dAHtmSLrU+krcwyzWXjKJPQe?=
 =?us-ascii?Q?PphLbZQ1eNgfrUVu2UDN6uF7ZFMaSVcaTwhEVFn669e9YNIQrYmmZ/Fe7XiU?=
 =?us-ascii?Q?Ii39CitrGyCVmggDCoEh+bweHnRP6fTJ+E2ZNhbpucrAtlCd7eAROhnYeP8v?=
 =?us-ascii?Q?z60gO2NgS4EPex59VAwFXbYLeW7dtzUjZfNnW9QM7EZw8+h2+EBvYSpfld5i?=
 =?us-ascii?Q?MBaA0xBy+F2AmJ3DJc2ELrYeFLCMQQXL9ulNnuTOMS1MMKuCk/ySdF+xU2Qa?=
 =?us-ascii?Q?LQ=3D=3D?=
MIME-Version: 1.0
X-OriginatorOrg: microsoft.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR21MB1439.namprd21.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e72eebf9-00f2-489e-7952-08d9ed9e4153
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Feb 2022 20:37:00.4991 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 72f988bf-86f1-41af-91ab-2d7cd011db47
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: JrWY1AyPNVFm2qVlMSX0L3o+NLNexuTslyHpc6uJNEDNdf3umwotA+KiqTxa4oavEeYMV9nHfYOp4uvO5kO/GJ+Z7Q3H9BMcziKEcqO+YKs=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR21MB0467
Subject: [lustre-devel] Memory issues with bulk rpcs and buffered I/O;
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

Hi,

I'm still trying to get to the bottom of recurring OOM issues relating to: https://jira.whamcloud.com/browse/LU-15468  Any help is greatly appreciated, even if it's just "here are docs on bulk rpcs / ptlrpc / etc".

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
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
