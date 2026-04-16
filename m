Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 998D9F8D761
	for <lustre-devel@archiver.kernel.org>; Thu, 16 Apr 2026 17:08:16 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4fxPYb57KRz23Tx;
	Thu, 16 Apr 2026 10:06:27 -0700 (PDT)
Received: from CH1PR05CU001.outbound.protection.outlook.com
 (mail-northcentralusazon11020072.outbound.protection.outlook.com
 [52.101.193.72])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange ECDHE (secp384r1) server-signature RSA-PSS (2048 bits)
 server-digest SHA256) (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4fxPXH56P8z23Rv
 for <lustre-devel@lists.lustre.org>; Thu, 16 Apr 2026 10:05:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=M3cFowMmAlyRtv2uf19ngeHBoaODOmmISIWVRqCdmX9/WuzDuUmIsD3iu9ikTOnq8rbJeq5RY6Yl7y4zt/4t5yVCphq3Yu2S3PRmqR9WUUVtIVPoxXCeLFlDzu3kTdTIerCCNAb3u2s2UykDtBFlkhXYhflHfX6MJbQzB/k5mwJzPI7D+Fy9X3yZzLXe+zx7hFi1CIMu31uY0CEHTIi+8U3aIcqKpxAxJIt7GV0Mn/BP5QPOOND5aI/qoIFfcbOMpGqYJsDWyE230rLJj/NcVpvAVvmfdELFkLd2en+600+lK0fsIw3Vd0tpnH+wr0mjpIcYAUutJ0BzabboJTxzjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=yhyvHIJuFsjUcPNQQawa4dQQzdbOYzfT7Iq5XB6F/Ow=;
 b=q8xQ8dMISNlshs3qFsrfx92lnvtwBqngIbDfnwWltRA7EP8OwNm5yzfL7FmpwN/S8N614fDxEwCdK/mlM6wrI13P/AW0RTjDLcbqbQNf5IXVlWAITo5Dlr3FJS0cH6yaZZ4+C47X1XiZ1FdbPnqm5cnEsIioTCJihdixmeL1w2xCxK+rWv7NfHfCvkbNeK06Q4fQQMyhMYuJmdOFCRZ+4UlGwl8RqnkkXbAnT2HY7NhKd5Or/THtRdhMq8HczjQTWtpntwU4GFm1bWPMHAFvmrcG2FO1X1Y/OobP22rccBvUUB0ReQ5UhsNbgtfMe/z+BqA9xYYQkeOhhrgis5GC7Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=thelustrecollective.com; dmarc=pass action=none
 header.from=thelustrecollective.com; dkim=pass
 header.d=thelustrecollective.com; arc=none
Received: from DS4PR04MB9822.namprd04.prod.outlook.com (2603:10b6:8:2e7::21)
 by DM8PR04MB7925.namprd04.prod.outlook.com (2603:10b6:8:a::24) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.9818.25; Thu, 16 Apr 2026 17:04:50 +0000
Received: from DS4PR04MB9822.namprd04.prod.outlook.com
 ([fe80::376d:31a9:6ea8:f4d9]) by DS4PR04MB9822.namprd04.prod.outlook.com
 ([fe80::376d:31a9:6ea8:f4d9%5]) with mapi id 15.20.9818.017; Thu, 16 Apr 2026
 17:04:50 +0000
To: GEORGE ZHAO <georgezhaojobs@gmail.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [REQUEST] Reserve OBD_CONNECT2_PERFSTATS flag value
 0x100000000000ULL
Thread-Index: AQHczL9e383rwbHYKUi8AVRk+3FmgLXh7LoA
Date: Thu, 16 Apr 2026 17:04:50 +0000
Message-ID: <0804DBDB-B1A0-4E5D-AE13-BE41D7DEBDA0@thelustrecollective.com>
References: <CAFhHJgnOoQs94G7_8UsjkpBDp=dgY-BrdhWmy79cmAoF3F5XSg@mail.gmail.com>
In-Reply-To: <CAFhHJgnOoQs94G7_8UsjkpBDp=dgY-BrdhWmy79cmAoF3F5XSg@mail.gmail.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=thelustrecollective.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DS4PR04MB9822:EE_|DM8PR04MB7925:EE_
x-ms-office365-filtering-correlation-id: 968e6f16-ea5d-4367-ac18-08de9bda457e
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|366016|1800799024|376014|38070700021|22082099003|56012099003|18002099003;
x-microsoft-antispam-message-info: azxR43Xs6pv9KWOIJDQwrzxK4f+tbcop148JjNwiupfznueuHRg74H+4cVSgaXa258EpsOiWPYmPY1CEYvGAPeqfYXKRjDNgsVqx/kQRWNhDWzBmmb00XlmALOEXfVDvQs8VHYIhef53rcqLCfsxAyJT07MKWIA7wMqAGvuotXPK+llZHyZc/acM3shQbSZtQST4Ze0XylqhihUtSXhT8X8CLon3F9sKLJ4UqVJXSjtg04ibDgCeVUvvp1nlDm7S1vGWtR8QAJ9MQfv0gqoYCbbQ0yoVZoRATrVF9Q6yVowpPcicgVc4PmJOEWwwdTw3eY4gcB821fZg9hqMXF5cYcVQqItQoOlpQp+Ga2qfLZLaNh0r8OQ5DbEmiPXDnMihAP7a8cgZBEZOnlUVPA/Ed5wJha4zmk0diOQEARMGtCBVkHlowsBsY133QrwqOLCd/o4BObvFjx8PZJ/mPmrKWhcPRHpUalFpsh39L1AipwG+qytRW4moZMi8Dr1ASql0nBaDvdFcUeg3KubnPL4Z3HQzX30DnBz1KTaoSBKvr2SJE+FHcUl71TH7C6/iNSd2TVPhrndLvkB1MB5kLunFMu9QSKpsF0TnBZAqH9PSRcTfzx/H6SggbOvsviSV9TGu0ac7pusKzyKRhnyRyD8K+zr691OkopZ5dzjxE19z4lIcKaLbWE3kXM/pDUd5aALitiI+SRhciyoZP65OEjXg4YrPjWieiCltQdFGIlVDzYp/NG8WkpSkkgdgQtgNxqYzpfwCzl1V+64CXYzy/PN7JbS2cCYMJ1RmMdKm/tvAMRM=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DS4PR04MB9822.namprd04.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(376014)(38070700021)(22082099003)(56012099003)(18002099003);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?E9HY4Ar3z1Xyh23WJtSu6aSizAjLmFzcqBNqJHG4eKDsBRrIeAukxMUlmu9S?=
 =?us-ascii?Q?W9JPfi5YDbO0UZIsf7gDcblvQPdh91XLejHuqRA4aI6Clibq29G4sh1dsq9A?=
 =?us-ascii?Q?c9M/XS8nsLMvMSlcTDqn32cI8v1LQOaDtpOiDAvHeB7AYZOMAvSVvyFmUwpo?=
 =?us-ascii?Q?kOmkBsz45Q4E5G00hFTZa0klp++YxGL+hmR0sh72qPSnlZt1/KaaL2KDisIh?=
 =?us-ascii?Q?MmY5+pzvCk5rJjNUKBKUJzGdNZpEhqUunkQpJ8PcdnSODXEWNfO+i5pVenaE?=
 =?us-ascii?Q?1zpRjMgAoKAtxtQAvoVKY/PdPdmKLhh1msrtNUNeaeDj241cqz6Rk565pSsa?=
 =?us-ascii?Q?riPu5+MzzBCVN5NwvLXTD0zQqFjgBhkyq7y/fKjJdDEd86XMvQ1GxTAYlpNA?=
 =?us-ascii?Q?Kfn+hhLrxXfzSNKDzMbVGOGV7t91EoLkoXgm1RH/9N/4myNDl6f6mD2ktg0G?=
 =?us-ascii?Q?WfxfMi3VyztxYp/hhc0eJI09SwFMu/gvRO3Ye100i2EFVTHkpvQRt2DKxwsN?=
 =?us-ascii?Q?c8xcyzctchIdz/Vkjy3F74O3LPuujjGq5aik1wV1wUJW4oeNFi5lFzftt7ho?=
 =?us-ascii?Q?gESEABrFQ9Qjez/s4gFOtcQ0jJch3wwNPS9C+fwcjAyZaka8MrLsvkbE34d2?=
 =?us-ascii?Q?JCxI+YYn0HcFSlrMackkc0dsbCcncUil38KfWckCClT+NicC9U+uFxNVAqDt?=
 =?us-ascii?Q?1BVKAKO5INzA5Jqm+Of5Dqli1H2oThk6F8UEOVmVCEWAejl4YXOsRHoonuQ5?=
 =?us-ascii?Q?7UyiGU3RXPOdp3kXdf2DFlFKpUSzV4dXt6HPqqfz1lnrk+C5uC4TbqXYDurY?=
 =?us-ascii?Q?BNu8uyP6209U+w9Br9EIb+b1i09YZtPTI/rkL4BSW+1SkelFSohRE/eR98ii?=
 =?us-ascii?Q?J/QE79zuLAqzPCAnqj9Bvcs0sC3Ne0+RvKZgNhkk8Xts/ERABhDU77/+gK2S?=
 =?us-ascii?Q?fQiOMAxLow/yOHDozU8kb6Afu/MtH5+UdHtxnSqE+kSoUOUBCGp/n94j9ZPB?=
 =?us-ascii?Q?qr1yjESF949dFql3A2eSDgBK9rN2W9/Wvusci1qKXkFP4yvycxywt948n2B4?=
 =?us-ascii?Q?nCQbADmzkyYC9dZrBu9tAxcuTUbl1g1Zcd/QlgOQxAWn8B9QcRns/r7EUQgf?=
 =?us-ascii?Q?vIOSFuCmwhkfP0QWABZVphm4NvmUpErpo0hlAADAiVxnmNAvOH09xLhSTR3s?=
 =?us-ascii?Q?JTGgEzalvtZT52lRcipI8LQYAn8yccvHA1+7vdZb++Zj+2HkxAK3VouPapn+?=
 =?us-ascii?Q?5orA1PCTQPKklA/ts3oaKTpfUVHgJAW4GhOAPWvYtQDwRrm89w5gas9582/+?=
 =?us-ascii?Q?78yTe2GM+Q+zXJWilbK44GbDcO1ffCJtON0ywKgGiddrqVTMRJQoOjYTAR/y?=
 =?us-ascii?Q?ssxRxGxGp9ms3lbhTc97pQMXUyBrx7Fb6VfV4ah2o7SPy4rDCJHfrXXBTPkW?=
 =?us-ascii?Q?zoSYPow5DZtMBoK037N0175Xh9y3nbzTnIRh25/ggTtZ9PBSo+L4CBN7YPee?=
 =?us-ascii?Q?uuUo6r/4z5tdQElBl0z+5aTT24P7FYhtmhADn+GRUMkCQLZ5vaTseFeQ9CAA?=
 =?us-ascii?Q?L4wW4m1cINHKj2vQrftizu7AHoIyIsFpqfisKyR6joF4XBDtMTLiAWMmkaE2?=
 =?us-ascii?Q?PRw9rHUF4AZlldxa6W1OsRZQm+T6h0+9+lQWQ6EJybDfa8zF2VzLuIw9A+bW?=
 =?us-ascii?Q?LVfV1crNPi2hydR4ljsb9E5O0oof37sVghYewhi9ynnNx+U/pyXFgR1tJ9AA?=
 =?us-ascii?Q?M+43fUpK9zfSh8ItmaXgvxTbB5yuzaX6194UA2zF/e7yOZpXnWBm?=
Content-ID: <7ACD5FA814EC68418F59928008034272@namprd04.prod.outlook.com>
MIME-Version: 1.0
X-OriginatorOrg: thelustrecollective.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DS4PR04MB9822.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 968e6f16-ea5d-4367-ac18-08de9bda457e
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Apr 2026 17:04:50.4223 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4c9dec06-8f2c-4233-98d5-ca3cb36218fc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: IDde9qD52PiB4O9bHbt1Cty+a0vKPTI6JW7P6QCTIgjfIbzVTshMuVQwp1Pbb9hwXvUjC37N46hHQoeUXwNSiWER/O1LTsbEoSnODwe4aM0=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM8PR04MB7925
Subject: Re: [lustre-devel] [REQUEST] Reserve OBD_CONNECT2_PERFSTATS flag
 value 0x100000000000ULL
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Reply-To: Andreas Dilger <adilger@thelustrecollective.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Hi George,
I've seen your patch and confirm that this does not conflict with any in-use
flags.  It isn't totally clear that a compat flag is necessary in this case,
but it is OK to reserve the flag and then it can be un-reserved if it turns
out not to be needed.

Cheers, Andreas

> On Apr 15, 2026, at 04:05, GEORGE ZHAO <georgezhaojobs@gmail.com> wrote:
> 
> Hi Andreas, hi lustre-devel,
> 
> I would like to reserve the following OBD_CONNECT2 flag value for the LU-7880 feature:
> 
> #define OBD_CONNECT2_PERFSTATS  0x100000000000ULL  /* perf stats in statfs */
> 
> Jira: https://jira.whamcloud.com/browse/LU-7880
> Gerrit: https://review.whamcloud.com/c/fs/lustre-release/+/59547
> 
> Once confirmed, I will submit a small standalone patch to reserve this flag
> 
> Thanks,
> George Z. Zhao
> 

---
Andreas Dilger
Principal Lustre Architect
adilger@thelustrecollective.com




_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
