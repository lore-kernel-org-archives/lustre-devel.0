Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6D4FCC433EF
	for <lustre-devel@archiver.kernel.org>; Sat, 12 Mar 2022 00:02:03 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 62F1421CADF;
	Fri, 11 Mar 2022 16:02:02 -0800 (PST)
Received: from NAM11-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam11on2068.outbound.protection.outlook.com [40.107.223.68])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8151921CAB1
 for <lustre-devel@lists.lustre.org>; Fri, 11 Mar 2022 16:02:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=gy2V5PdXORKDvHKIb5pwrQqVR8DQ28ZjO6OpDCnNQ8ntnNfYDDWgO+Q1JXq/prfPukJDqBMao+Rr282cYzQ+BSX3htxDYe3ABPVzvJKeYXnbR/xyOAqH/zAe+MLkxz2dP+Meb2irHYwUOU0CFQWar9/YzQZL72oigtf7HFJpOnU9iMjtbs9sNqPQ+x5m+HZyvZy/qoqEfYNHza5JwT2NchLS0XWbE6wZ+pn/25BiSgnQKNQHpP86gIrzkSSWzmcgR2XgBHHzOhuMx2EKYwGRkOW1PtLelpOBJuPm2KRl23uGlvbT2vwoOVUr30nXc2ege0bESAU3BvX0DEbLgidV2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=t3blGl9X6ewxkc0C8l5F576E00kW93uzdaap0qW/T7I=;
 b=VyngOlzvUlkRYd//hWAPLtUreUd1vtGrVKyRbMo2sYsmDPYMc+HjxPlYXcacLQvdEG9djGePn52uCL931rFoHxL+U2v4KEMJt0cLbUL+ZqG3Mfl+gSqeZDoLH52rlQlZeIl6CQj2vS/uG1Em/VwUZcDUbjb+kpx0hJ+cv1jdwvENi9PR7dzSW9fEglkaBu7rIpZDPocssJPJIpJGLDAR8ITfauPWx90uH6XFu/49VYw/JZF3XZ9/7Nae82t9l/kS+gjx8YpzK8yKZo+Rd60wgGqYLWzXpbwc5HTEadbtdavl+LdP+nvhfpdrvxsboEAEnrO0x6HSbuNVxY1dkxwBhA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=t3blGl9X6ewxkc0C8l5F576E00kW93uzdaap0qW/T7I=;
 b=HQB0qWSoJ5nSsy0iVMKR2BOLGjIGOqclsfH0xXsQE0bVstA78NxEywscQZkgkx2DkHhLoQ3+q/tb1c8O/KRMdsJlz0cffKv9DXaBpLidJQOxVemla0KN6fcKq4JsLRn3kxQgW4W+BcwH7MsBIzLp1etMrAY6zEhHI8RvowtwudY=
Received: from CO1PR19MB5208.namprd19.prod.outlook.com (2603:10b6:303:f7::24)
 by MN2PR19MB3341.namprd19.prod.outlook.com (2603:10b6:208:135::25)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.5038.17; Sat, 12 Mar
 2022 00:01:57 +0000
Received: from CO1PR19MB5208.namprd19.prod.outlook.com
 ([fe80::408d:18b7:a981:d8ed]) by CO1PR19MB5208.namprd19.prod.outlook.com
 ([fe80::408d:18b7:a981:d8ed%8]) with mapi id 15.20.5061.022; Sat, 12 Mar 2022
 00:01:57 +0000
To: Kevin Zhao <kevin.zhao@linaro.org>
Thread-Topic: [lustre-devel] lustre:pcc: Sanity-pcc 7a test hang(Both on
 Aarch64 and X86_64) discussion
Thread-Index: AQHYNSCqZewVLQWCU0uccbkCYJXA5Ky63oQA
Date: Sat, 12 Mar 2022 00:01:57 +0000
Message-ID: <C7B35B3E-0002-41B3-A653-46966DE7E15C@ddn.com>
References: <CACzn6-UFqbF+rb1wvDJQ=6+jrHDsEZUufa8AG6vY5izH+KNNVg@mail.gmail.com>
In-Reply-To: <CACzn6-UFqbF+rb1wvDJQ=6+jrHDsEZUufa8AG6vY5izH+KNNVg@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.21)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 421f97b9-bcdf-4ee3-4279-08da03bb86a3
x-ms-traffictypediagnostic: MN2PR19MB3341:EE_
x-microsoft-antispam-prvs: <MN2PR19MB33410D0FBB922F0CAF242428A70D9@MN2PR19MB3341.namprd19.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: 8UhM3uRcf3qpAYQ7NsLixJ/ThYfuodPLwsksH/35sEQq2zUz3ITTnk1Z7MOgYf15ngssdSkwgUIBX1A1CzzzKSteHweMCa4PPaNSC/vO/FqDZrRmXzpBJep7ZgweU1Yu/2OOrQxK/23NXCUTNlAR9qd3OrsLdRC1vq4/f/TpzIwiJsXO6pdzGJ1lsQp4RJH8iWjt55zGUuFC4lwdpau0yE82893+3LFGmSSxaT84lNZcMeJm7LD4gqEwAuROye5YqmNNaU2p7BqXhv273ZEBjSfjLdpEuepyLWUhbBqGqTqt5ntiKA56rmiOR6m/3k1nfvuULpcUmTpKWgYM/hepZ6XF3r3t/P7eKWv00mNo7XNiYOZsG1/2wQ0VZy7xNnG4iycq/HLXxyPVZBgJoPDlY0WHsV9/djgbZyFOwpzxq08yfpMWoL6m+9GJHi4m/neWqYnwJVEJvkP2vVhRhCBzTVHktA8BnFSep24MMk0knuC+RokHPWonjITMwh/3Of34+lzZ/D3hkBUzsH1XUPqhFJFHnKjsLhAaOS28V89vwfcPO0+QXzM22q1EAsZmeZ5te+8U7U8iptnO05JNTf7cj1APHgW1POlCrByP/CEK4GictbFtAykzB1Z4wUaSwuaGdUfGvw3ONGwEUlKkDS4kjXfcqkLESaDPDxZoMeCN+YUL0YDAq1bJjhypbGWByyem37KmYJGhUWSh4pr5kO+96pJCaaD1/O7fel+hMaV77Dg0HtmTnJEYxAUhmXFzrTom0HiBPGuB8i3OCYclys0JdecKIqs4tvagC+oevuwbRMFkVYV5c8zZGhSMpgRz6wRwuZZ+RN2lQu5XpWeGIOgSZNqLzkkZCRuBZSMTvT9F2aY=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:CO1PR19MB5208.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230001)(4636009)(366004)(36756003)(53546011)(33656002)(6916009)(71200400001)(6512007)(6506007)(8676002)(2906002)(66446008)(66556008)(9686003)(66946007)(316002)(64756008)(76116006)(8936002)(4326008)(38070700005)(86362001)(5660300002)(38100700002)(54906003)(66476007)(6486002)(122000001)(166002)(966005)(83380400001)(26005)(186003)(508600001)(13693001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?5uEaMh8Q8KJWYydrMXY1vR2ElOLGsu4i+QaCFvr27ynQq191I3MXEFPdprqf?=
 =?us-ascii?Q?/XDGK9uOIRr6R6JXlLKAaQcspciZGsdsZPsloM5AfjiVVmD6iP2FCVZaYJlb?=
 =?us-ascii?Q?4H99QotDkdkoLZIuCXum1N7pqNZHpy8e6V2HhwiY3ElTRBPvXa52IgeSBRVY?=
 =?us-ascii?Q?Y7xEwv6XomhGHOGBGpS9XY15+JIQOggINK8Gn9beADkaaRraDpqBJA8d968b?=
 =?us-ascii?Q?xl3oeYUbQmeTH0R3CG7K4ENgPHgMF2EHa1VCTPQD7QAGwBpdtU9sB1R4OXlk?=
 =?us-ascii?Q?ZM5oL6V8UL3QqkhNMrWbPZXKl+IzaVua0ZgfxJP/rilH7eJ1/XT4n9C+/SV8?=
 =?us-ascii?Q?fY61WNJx8J7yc9Xw/Go9Wt9Ei7UsNVMf5YvTTUvmvOqqWcNIUBNU9VMsakLr?=
 =?us-ascii?Q?nwxsHNojSr9t3QakiyezGE03BXnEEue1n9b8diFB/6Bobq4Copnov3+pL+MX?=
 =?us-ascii?Q?ERdEfU9PGmhXza69SODdkwRTD8WO7GGnCHz89Kq3LCoSvw5jBZuxT1dFUVHn?=
 =?us-ascii?Q?dKgFLl+ltlDGer8b5kp8EYzFJ5/cALU4+Xu4VgurIVltKBh1IdeMIJNmtaev?=
 =?us-ascii?Q?+Voi/deZGqXhJ3zlqBLcjBrZPOij6EFagAmKiPLIaZUPpksSPnRYJG3zIj/l?=
 =?us-ascii?Q?bPej4Obvkz0VWTUP+YQKcEfmxBsn6adfxiv56tyy+ciQS+oj7Qdznm2PNXut?=
 =?us-ascii?Q?AdDOZeHWGz9YalUjm2eOa/gYWJkLjN2ImmOJItHI0NeZm2JPmBkleampYc8z?=
 =?us-ascii?Q?7UP8GuBl95FWNQLA735CAYZhCxwWl6oSK1Jh9x8m8QduxHM8pANCoxGBRujB?=
 =?us-ascii?Q?APm94eogNYUXwP7NC55s8CgL4A7ORI5YlQQU9Tp9BlQZDzV1sCrNY2ogGSXu?=
 =?us-ascii?Q?rix9UqhiyELZb9hh/V3DYyeXe3qG6V0KSiWfWXEVSlQBOAW7MEYQKNEOS+ma?=
 =?us-ascii?Q?uIoUw3E+0Zq3ulbz6Yds/DXp6tnyN8zgXtoGaD0k5ur8oJRyc7wA7eF47Yjl?=
 =?us-ascii?Q?6SkR55C1nOF0cPcsp+YyDmQ9Fmxj1Hn+KP2hRUxNtQgVJZWNK8UfN15JkeKD?=
 =?us-ascii?Q?RFhXBFNgD/ERDqse9kcRtOOooh8ZiJygubD+wg966rk8Ep6b4XMBjcgwpws3?=
 =?us-ascii?Q?I8zaZmRca0e+v8Z44bs9fBSbzP82gAufgpEKSLUdJeQ+N9yv9J9StHR95Bnf?=
 =?us-ascii?Q?iGXtfPEOpy0Cjd+BKXMBV9NzP5tzaIWFMHW2EMRWqXOYrPzSdebAHXC1cT+H?=
 =?us-ascii?Q?bh6iWmMZbU1GWyr0+UkEcn+r4edIYkhOoIYgOgeTbQc5f+x5a+yadsl3N+KC?=
 =?us-ascii?Q?Buy2tofWWuRZO+rb1C7rLXW9Kvbf5bwdMkkFswx+J5r8S3URo1oxs2S41PD/?=
 =?us-ascii?Q?qMRZ4rkJYp7jmHkHsjxi5gXt1UesQabbx3cim7/l6tMpdoqpmrFCA2dGUhKp?=
 =?us-ascii?Q?07szi9RT/cY1+k8QC5+xSpIFRrPkkL+9/5xPuh0/XmpGvgRaCnuZbsdn0ahb?=
 =?us-ascii?Q?owOSmnvrjUwqKHxggf2oOiI5SCWErIn5w2NBK61MVBn39THdHOH8u4SokxK/?=
 =?us-ascii?Q?O5r9Ai5MGhyOLxNCcPI=3D?=
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: CO1PR19MB5208.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 421f97b9-bcdf-4ee3-4279-08da03bb86a3
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Mar 2022 00:01:57.6929 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: QMEg7yBCFAzBBQyxdUzxAG4BLv4rM8r860/D2//BAoSdW/LoPvBqfAV+awWa7g+K
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR19MB3341
Subject: Re: [lustre-devel] lustre:pcc: Sanity-pcc 7a test hang(Both on
 Aarch64 and X86_64) discussion
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
From: Andreas Dilger via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Andreas Dilger <adilger@whamcloud.com>
Cc: Li Xi <lixi@ddn.com>, Lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============7955567598680177459=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7955567598680177459==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_C7B35B3E000241B3A65346966DE7E15Cddncom_"

--_000_C7B35B3E000241B3A65346966DE7E15Cddncom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Kevin,
Qian  has a patch https://review.whamcloud.com/40092 "LU-14003<https://jira=
.whamcloud.com/browse/LU-14003> pcc: rework PCC mmap implementation" that i=
s changing the PCC MMAP code significantly, but is waiting for the 2.16.0 f=
eature landing window to open.  It needs to be refreshed, but it would be h=
elpful if you could take a look through that patch to see if it would resol=
ve the issue you are seeing.

On Mar 11, 2022, at 01:18, Kevin Zhao via lustre-devel <lustre-devel@lists.=
lustre.org<mailto:lustre-devel@lists.lustre.org>> wrote:

Hi,

Recently we've worked on the bug https://jira.whamcloud.com/browse/LU-14346=
. This bug will make the mmap write hang forever. This one is first occurri=
ng on Aarch64, but if we do a small change<https://github.com/kevinzs2048/d=
evbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#reproduced-on-=
x86_64-with-a-small-change>, we can easily reproduce it on X86_64. For more=
 details analysis of this bug, you can also check the link<https://github.c=
om/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.m=
d>.

The hang location is here<https://github.com/lustre/lustre-release/blob/mas=
ter/lustre/tests/multiop.c#L725> as below:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
    case 'W':
        for (i =3D 0; i < mmap_len && mmap_ptr; i +=3D 4096)
            mmap_ptr[i] +=3D junk++;
        break;
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Bug Analysis - different behavior when run mmap_ptr[i] +=3D junk++ on diffe=
rent platform.
Traditionally, this process is:
1. read from mmap_ptr[i]first(Execute the read page fault)
2. Write a value to the same page(execute the page_mkwrite to change the pa=
ge to writable).

But on different platforms, it executes quite differently.
On aarch64 platform: do_page_fault, no FAULT_FLAG_WRITE set, so handle_pte_=
fault will call do_read_fault

  *   do_read_fault:
            __do_fault -> call ll_fault, get a page from pcc_fault
            finish_fault(map the returned page to page tables)
            unlock_page
            vmf->flags is VM_FAULT_LOCKED
  *   call do_wp_page --> do_page_mkwrite --> ll_page_mkwrite

On X86_64 platform, the mechanism is different. On X86_64, do_page_fault, w=
ith FAULT_FLAG_WRITE set, so handle_pte_fault will call do_shared_fault.

  *   do_shared_fault
     *    __do_fault -> call ll_fault, get a page from pcc_fault
     *   do_page_mkwrite-> call ll_page_mkwrite
     *   finish_fault(map the returned page to page tables)
     *   fault_dirty_shared_page

Bug Analysis: why hang forever:
Also can check: https://github.com/kevinzs2048/devbox/blob/master/notes/lus=
tre/pcc_sanity-pcc-7a-analysis.md#kernel-do_page_fault-process-analysis for=
 more details.

do_page_mkwrite--->ll_page_mkwrite.
    Insert the issue 0x1412 OBD_FAIL_LLITE_PCC_DETACH_MKWRITE.
    Return with VM_FAULT_RETRY | VM_FAULT_NOPAGE
    RETRY again, due to PTE is not NULL, vmf->flags FAULT_FLAG_WRITE, will =
call do_wp_page again.
So that next time we will enter into do_page_mkwrite again. hanging forever=
.

Seek a good solution
As the above code snippet shows, we want to let the kernel retry the mmap w=
rite (->fault() and ->page_mkwrite).
In handle_pte_fault, if there is no page or the page is not mapped(no PTE f=
ound), then
 __do_page_fault will try the memory fault handling.

The easy fix here is to remove the page and page table entry when we do fai=
l injection in pcc_page_mkwrite. But I don't find a good method to execute =
this, so list the info here and ask for community help.

Some tried fix is:
add function: generic_error_remove_page, but the mapped page still can not =
be unmapped successfully. The error log is here<https://github.com/kevinzs2=
048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#solution>=
.

Since I'm a newbie to Lustre and not quite familiar with the memory managem=
ent process, so please give some advice on this bug fix. Thanks in advance.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud








--_000_C7B35B3E000241B3A65346966DE7E15Cddncom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <A3C7BC696477B04DB8E7D63F1C3EA0FF@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
Kevin,&nbsp;
<div class=3D"">Qian &nbsp;has a patch&nbsp;<a href=3D"https://review.whamc=
loud.com/40092" class=3D"">https://review.whamcloud.com/40092</a> &quot;<a =
href=3D"https://jira.whamcloud.com/browse/LU-14003" class=3D"">LU-14003</a>=
 pcc: rework PCC mmap implementation&quot; that is changing the
 PCC MMAP code significantly, but is waiting for the 2.16.0 feature landing=
 window to open. &nbsp;It needs to be refreshed, but it would be helpful if=
 you could take a look through that patch to see if it would resolve the is=
sue you are seeing.<br class=3D"">
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">On Mar 11, 2022, at 01:18, Kevin Zhao via lustre-devel &lt;=
<a href=3D"mailto:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@li=
sts.lustre.org</a>&gt; wrote:</div>
<br class=3D"Apple-interchange-newline">
<div class=3D"">
<div dir=3D"ltr" class=3D"">Hi,
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Recently we've worked on the bug&nbsp;<a href=3D"https://ji=
ra.whamcloud.com/browse/LU-14346" class=3D"">https://jira.whamcloud.com/bro=
wse/LU-14346</a>. This bug will make the
<b class=3D"">mmap write</b> hang forever. This one is first occurring on A=
arch64, but if we do a
<a href=3D"https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/p=
cc_sanity-pcc-7a-analysis.md#reproduced-on-x86_64-with-a-small-change" clas=
s=3D"">
small change</a>, we <b class=3D"">can easily reproduce it on X86_64</b>. F=
or more details&nbsp;analysis of this bug, you can also<a href=3D"https://g=
ithub.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-ana=
lysis.md" class=3D""> check the link</a>.</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">The <a href=3D"https://github.com/lustre/lustre-release/blo=
b/master/lustre/tests/multiop.c#L725" class=3D"">
hang location is here</a>&nbsp;as below:<br class=3D"">
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br class=3D"">
&nbsp; &nbsp; case 'W':<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; for (i =3D 0; i &lt; mmap_len &amp;&amp; mmap_p=
tr; i +=3D 4096)<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; mmap_ptr[i] +=3D junk++;<br class=
=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; break;<br class=3D"">
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D""><b class=3D"">Bug Analysis - different behavior when run&nb=
sp;</b><b class=3D"">mmap_ptr[i] +=3D junk++ on different platform.</b></di=
v>
<div class=3D"">Traditionally, this process is:<br class=3D"">
1. read from mmap_ptr[i]first(Execute the read page fault)<br class=3D"">
2. Write a value to the same page(execute the page_mkwrite to change the pa=
ge to writable).<br class=3D"">
<br class=3D"">
But on different platforms, it executes quite differently.<br class=3D"">
On aarch64 platform: do_page_fault, no FAULT_FLAG_WRITE set, so handle_pte_=
fault will call do_read_fault
<ul class=3D"">
<li class=3D"">do_read_fault:<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; __do_fault&nbsp;-&gt; call ll_fau=
lt, get a page from pcc_fault<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; finish_fault(map the returned pag=
e to page tables)<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; unlock_page<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; vmf-&gt;flags is VM_FAULT_LOCKED<=
/li><li class=3D"">call do_wp_page --&gt; do_page_mkwrite --&gt; ll_page_mk=
write</li></ul>
On X86_64 platform, the mechanism is different. On X86_64, do_page_fault, w=
ith <b class=3D"">
FAULT_FLAG_WRITE set</b>, so handle_pte_fault will call <b class=3D"">do_sh=
ared_fault</b>.
<ul class=3D"">
<li class=3D"">do_shared_fault</li><ul class=3D"">
<li class=3D"">&nbsp;__do_fault -&gt; call ll_fault, get a page from pcc_fa=
ult</li><li class=3D"">do_page_mkwrite-&gt; call ll_page_mkwrite</li><li cl=
ass=3D"">finish_fault(map the returned page to page tables)</li><li class=
=3D"">fault_dirty_shared_page</li></ul>
</ul>
</div>
<div class=3D""><b class=3D"">Bug Analysis: why hang forever:</b></div>
<div class=3D"">Also can check:&nbsp;<a href=3D"https://github.com/kevinzs2=
048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#kernel-do=
_page_fault-process-analysis" class=3D"">https://github.com/kevinzs2048/dev=
box/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#kernel-do_page_f=
ault-process-analysis</a>
 for more details.</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">do_page_mkwrite---&gt;ll_page_mkwrite.<br class=3D"">
&nbsp; &nbsp; Insert the issue 0x1412 OBD_FAIL_LLITE_PCC_DETACH_MKWRITE.<br=
 class=3D"">
&nbsp; &nbsp; Return with VM_FAULT_RETRY | VM_FAULT_NOPAGE<br class=3D"">
&nbsp; &nbsp; RETRY again, due to PTE is not NULL, vmf-&gt;flags FAULT_FLAG=
_WRITE, will call do_wp_page again.<br class=3D"">
So that next time we will enter into do_page_mkwrite again. hanging forever=
.<br class=3D"">
</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D""><b class=3D"">Seek a good solution</b></div>
As the above code snippet shows, <b class=3D"">we want to let the kernel re=
try&nbsp;the mmap write (-&gt;fault() and -&gt;page_mkwrite).</b><br class=
=3D"">
In handle_pte_fault, if there is no page or the page is not mapped(no PTE f=
ound), then<br class=3D"">
&nbsp;__do_page_fault will try the memory fault handling. <br class=3D"">
<br class=3D"">
The easy fix here is to<b class=3D""> remove the page and page table entry =
when we do fail injection in pcc_page_mkwrite.</b> But I don't find a good =
method to execute this, so list the info here and ask for community help.<b=
r class=3D"">
<br class=3D"">
Some tried fix is:<br class=3D"">
<div class=3D"">add function: <b class=3D"">generic_error_remove_page</b>, =
but the mapped page still can not be unmapped successfully.
<a href=3D"https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/p=
cc_sanity-pcc-7a-analysis.md#solution" class=3D"">
The error log is here</a>.<br class=3D"">
</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Since I'm a newbie to Lustre and not quite familiar with th=
e memory management process, so please&nbsp;give some advice on this bug fi=
x. Thanks in advance.</div>
</div>
</div>
</blockquote>
</div>
<br class=3D"">
<div class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Lustre&nbsp;Principal Architect</div>
<div>Whamcloud</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
</div>
</div>
</div>
</div>
</div>
<br class=3D"Apple-interchange-newline">
</div>
<br class=3D"Apple-interchange-newline">
<br class=3D"Apple-interchange-newline">
</div>
<br class=3D"">
</div>
</body>
</html>

--_000_C7B35B3E000241B3A65346966DE7E15Cddncom_--

--===============7955567598680177459==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7955567598680177459==--
