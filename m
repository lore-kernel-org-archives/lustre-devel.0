Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9D3BEC27C53
	for <lustre-devel@archiver.kernel.org>; Wed, 12 Jun 2024 23:58:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4W02Xf05bHz21Hy;
	Wed, 12 Jun 2024 16:57:38 -0700 (PDT)
Received: from outbound-ip168b.ess.barracuda.com
 (outbound-ip168b.ess.barracuda.com [209.222.82.102])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4W02XB5mLvz1wLF
 for <lustre-devel@lists.lustre.org>; Wed, 12 Jun 2024 16:57:14 -0700 (PDT)
Received: from NAM02-DM3-obe.outbound.protection.outlook.com
 (mail-dm3nam02lp2040.outbound.protection.outlook.com [104.47.56.40]) by
 mx-outbound17-50.us-east-2b.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Wed, 12 Jun 2024 23:57:11 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=gWh6UQRGDiakp1qvfxhVOc2NawGHmNgX5a4bR2I5AR6DTfB5wtlvj/hftp2H4eXWr0yBEP9LBVTVAzYD8dLkUsGSya6L7jPrVsosB/134HtF+SI1JWw5wku1YZj2+yTbNczN3hWWqKGjAeanut5i86wy4cgyD/2GeImxSczBfR4BLzEDwIdPE8hqr+HlRB9cJAVf56uugn2Wl1goh1JkPZSND6BCy0PbrJsJPZwmlvzK5+66vIxuq0tcZZDZ69LhHWfEukOQSdE27y9nuJQryhYIAhZKRIwiZm8W9jb2kjFFn9YVrAR5i0/6H+LyJ6Mu6GCE3eCHm1KfWxbDn4d//w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=gs+4fbS6jCEQJMj7WQ716db7LY5QrHwzKJAqJbDnN3c=;
 b=Pn9j0XSqk8ajYFpxBe3DZHtPtdbmLNYd4qhKo5a8vvu4uaKmEDR/O7534KvIhHoTl4ljyX5M2mzBzUs0ZFdHEv9YhlpMxCAHWveJTibp+mGT+Je6Gl6IY/bbYR2cvkvI8XNiuCNXhJivFfO4RjRJHIV9OdDW+S0O8kxQ9BK2xLVQX8Br3d/2lmb+xAv8Zhb/47r25xbXcvZTbYx457MHCSxbmhlllrHuackwncfTsFszkylEcE8C3xwniVBAjINUiSy6v35rimKJRJzoQ5DcK/dA7aG/bnAdP4YCaC3VOnm3n3YTWIItEtUYf2AoW2v/ZHgCAaQ6zsHBXVz8OH6MDg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gs+4fbS6jCEQJMj7WQ716db7LY5QrHwzKJAqJbDnN3c=;
 b=a0fiXNStSoe1daa7DZ7C/87LDLuUrMgmiEwIpMWMbFcLTVpC1O1NuM1Y+tihmxQ+Cla9qa9A/xDiQc7MJeDqdJaOOXt3IUqB4OXLLhX1HdqnVyqjMsizTCZ8D1nPGq33B599i8QTbjbiS9Twf1K/lW+oliU/ZBsnXNVquvE6ggo=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by MW4PR19MB5565.namprd19.prod.outlook.com (2603:10b6:303:168::20)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7633.36; Wed, 12 Jun
 2024 23:57:06 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2%7]) with mapi id 15.20.7633.036; Wed, 12 Jun 2024
 23:57:06 +0000
To: Patrick Farrell <patrick.farrell@oracle.com>
Thread-Topic: [External] : Re: [lustre-devel] Inquiry Regarding Checksum
 Support for Lustre Extended Attributes
Thread-Index: AQHavPd4erDY+MuQ20qhjIELCkzfDLHEtYQAgAAHdACAABGNgA==
Date: Wed, 12 Jun 2024 23:57:06 +0000
Message-ID: <AE0CD2DB-6E84-4727-8D82-4C1B06BBF627@whamcloud.com>
References: <CACyzrcS7iBzxmzUqLY7vo0gE_=D3v+33HZ_gGeYe6rgkv0YYOg@mail.gmail.com>
 <D862AC2B-4FFA-4F82-992F-246E24BF4C72@whamcloud.com>
 <SN6PR10MB2813B942D02E953B1786419899C02@SN6PR10MB2813.namprd10.prod.outlook.com>
In-Reply-To: <SN6PR10MB2813B942D02E953B1786419899C02@SN6PR10MB2813.namprd10.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.21)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|MW4PR19MB5565:EE_
x-ms-office365-filtering-correlation-id: 9648512f-ba6c-42b1-2ebf-08dc8b3b5d2c
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230034|376008|1800799018|366010|3613699006|38070700012; 
x-microsoft-antispam-message-info: =?us-ascii?Q?ZCB6V3V9D80hpihZojZ64/HSYk2wBLjRDC13uilRf5Ig7Wm7yB8kqlz/KwqZ?=
 =?us-ascii?Q?NR5HoUJBnyxzsMNNZxh98gyG1TAwEfd11c8PRSsXl1cv8nsgxdyDGCKCxot1?=
 =?us-ascii?Q?3u6BV12TBhMUtxk7TsjGPB7Ttn20OivGXJ2viRvvZYkL2J9Uh7qDEPTGH45K?=
 =?us-ascii?Q?C1BCS3WygUqTOT0kZva9quICNUCD61Rv3+8zEmEPdXSNFJfPPKufuuLnNcvb?=
 =?us-ascii?Q?EeAre6qlVwd9gqNi3lFYYnHJbCu0YMCexMQvse9cIGI9RWO6LEyM/k5LGzdt?=
 =?us-ascii?Q?EbWCdTmA2tgVmCNHAR1ompaMrpRgfb4SjQh5U3Hs/4fGbXvX4pz+QAw5Uxhd?=
 =?us-ascii?Q?Ij7UPnuXC1bqC+TjdXWiFJV3akwnOP+o0z35IZtktSLt8gga/BMiZvlrVK72?=
 =?us-ascii?Q?WWFBa+i9ZSVYmKSlw4Z+dBzNayv0EshljNQPLdPszIo6CmM6CiG14asFHeH+?=
 =?us-ascii?Q?zyGG28rwhlMC4YgRXlt0lRQlm8nwxigMzdVQIuvOqc/eU4wgtNACrhNLvrbG?=
 =?us-ascii?Q?AVTdwYbnKdik49f7Dqv8ezZTrBAIFrIFzaVUPR/tnC3g/tA2M2bEwmfrd1hQ?=
 =?us-ascii?Q?uioTvyF2GI4ksr1ZfMOjxASgYWIdq4BV4zXIc64YVgzK/jgu59ZvzykZTCRM?=
 =?us-ascii?Q?QLH9GGsbunR9Mt73l3cUpu7ftgUidk+txsSF5n3okM1HUrwQaR2O6dVr86EY?=
 =?us-ascii?Q?SZiTDVn2sj4Ck/QZTXRpl0Wm/86xYtM5+jKDejb6xzOql3kbo3U3FVYvOfce?=
 =?us-ascii?Q?C2wc/DoOy+rrjJaSPcWT0xlit5UH+XSqTKRAHhvHbhC5+A0a4LCg2DJkHygS?=
 =?us-ascii?Q?QQgiRE38A2LHYl5PTPSI0yKbWPK/z7o4DTS9HUgpPERuvBTmYxoXxvIPNAo8?=
 =?us-ascii?Q?8dfy4yD0fJRrhsJBXoMSMfjUQzsvIUn7Vc9CexWIwjX48aoGXvKjXaD8mF9j?=
 =?us-ascii?Q?3b6+bITVNmBPtMaegN85rEMLc20c9p1MwI76UqP4kILxr8QGZxq3bE1jmbZF?=
 =?us-ascii?Q?XfDSow5GLiPkEKOhoZL6J3ZToQFy2yYrObIq8j2RL+9UgEeHT7Hxl5jx4pGu?=
 =?us-ascii?Q?Zvf+1h9l5velS9PTIJqoZn5AG446Fsv9/Rt+E6/fGQw0P26P8Vi15xeH64uq?=
 =?us-ascii?Q?BMjzLmiYfa/bep4osHAe8+skAuUI1noMid8jmOHhW9OVTZPskgrCO6mXB9cv?=
 =?us-ascii?Q?kEfmHzh5/wWe5xuiMttG9vIBSWi7zwZeXrDaFJFnmNnAdbmxqWQXxiac0QBB?=
 =?us-ascii?Q?XIDQ3Gy0RcWRYuwfCAiUV2RvqN5I8nfnmJ4Y/vMthr+RvMoxzqzrg9X4ajWM?=
 =?us-ascii?Q?vGY+SQ9RqBVtPJ8XYt7M61gN/mJ8c8M3jk00txQ2ReaLbNmaObvA/LrfZLxq?=
 =?us-ascii?Q?NadjhCo=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230034)(376008)(1800799018)(366010)(3613699006)(38070700012); DIR:OUT;
 SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?qOrqOhSju3E0Zgb/3XR/DFgdG/gh8xTtkFou5aDrffEMIbICz6dlN01WTcrC?=
 =?us-ascii?Q?eu+zwm/ZRs97rNNCzcyOo5tPF/kcx2e1GyWtVjvICeqyIhQL3Y5/WtpmMU25?=
 =?us-ascii?Q?Dn1eaNhCJAbG1+LeyBafrMihxttt92ctwyU5/1rKGNWndwW9SAyiIVcjGGBz?=
 =?us-ascii?Q?aJ+ssNmJTXxdbFKY6ikcesJ2Dzk1XJn/up3Hf2HlSYZKxxZ4Wwxx+Q0+Fb9M?=
 =?us-ascii?Q?yREoa8Q+JOPJUuVybVEEEBeL8co082YrpSrXTfR10lIuFG7320W3M2xERN9z?=
 =?us-ascii?Q?P0FNcL0+dAPASSlVg3ejUxJ4UyNVH0vF0mmO1kWaYPLoPql1y8kSch5OTF1J?=
 =?us-ascii?Q?DAK+zD30S3H7AB/KtqtsufL4JAgQtx1IcqYw9b/aCaTUsPzsqjIbY/YdH1Ll?=
 =?us-ascii?Q?N3N8Kq+kBFOq+xw17wJ1lDWl+9Bnosp4FB7U0k4Wpv1LMd5/EWFLTOSuEtpz?=
 =?us-ascii?Q?xzc+aIiXQ/lEy/k3cw+8VCBC0/OnvG8hQTikJTy5Yu0PwGDCn/S4YyIXHLe7?=
 =?us-ascii?Q?bDF+NTswylUlwHUilLJt0A6j5wfAuT8TC0JccErF9zXg46AN/xptEtOk6C6D?=
 =?us-ascii?Q?eYSo3tOSvofpTkh+32S3gIKngwKhanNfgMKVeOqjpG/y3bFxloOt+xBn5Slx?=
 =?us-ascii?Q?tNHbtLbbOYin3PQ/c+KbrhMkt3eqvaQpEDJUsafbExBcNPrfQk+h5LnnPoBJ?=
 =?us-ascii?Q?Ih/c5odN2M5AXylK/37XhaHM1qA5Orgw7J7jHHhobwF8mNFVLlMKBvLzaa6W?=
 =?us-ascii?Q?6y2oGbpBCyPrgPIJGmgUfG9YeqU9qbGjiBd3Y40eq05CF1TLjJZHppYu9Di2?=
 =?us-ascii?Q?/lDT5oKbYPOxrdeJI8O1fkbgthDPPv6QMbqYIC3v9xXNapD2MOOCpYK8h/2b?=
 =?us-ascii?Q?P9DRhqrpGeUSo1KhXu/Bt2Iw1merDeyuFYBo6EIYEtOFydIHWN1BqWKvNLv3?=
 =?us-ascii?Q?Hwld9ahHzUXSQujewN8sKXNPXhPZSr73G8uWgdZX+bwpVKY4E/JN/7+jGHG9?=
 =?us-ascii?Q?nF9s5iGHxrf9hudKJQWJyqnePHEav0mdAuxv8Omn+BkT4DcjV7YKUTSo2z9D?=
 =?us-ascii?Q?5ICsIQAFCIN0bfH1UGmQrPajQtg+wkYgeQd9jwyVpPp+2N+4Sr3qw/2aMmA2?=
 =?us-ascii?Q?V6+gAO9M96eFZ3rWGMSa/STAivzlFSF5GKEqmavlJBb0z68F5dREtiN5Z1p6?=
 =?us-ascii?Q?muVq7Kuqjf7BXCmkIKFNc6KqnYgfhV4sRTRaOHgBL6FcgeJFW91QAV0/mV6F?=
 =?us-ascii?Q?JZ68NM1iWxTiev5I2rujUUGHPXhyX2+9KyLvJY1cx8OHGPvuWUoE61STbY1K?=
 =?us-ascii?Q?yrzJaRu8wKOA2BVOacVtoZZGl5UR8JIpfSgMRQnARWeMlJ4X4Iu+iCw8H1U+?=
 =?us-ascii?Q?lrsheuRfCaSk2bvZA+pw0s+weI4HJWp9kxziPtcul8MQ5xTDPufsujJE9chE?=
 =?us-ascii?Q?qrqD8CW1FsQwYq2BM2eifNFSVgX+aORJNOXjavPtHW1+crZjNLuuRmGUbMVG?=
 =?us-ascii?Q?ZpU2IpbrGwywswfQTK624wIgniiJx9EgXWz9CC3vBzVxZAueqD3j+jYdqgex?=
 =?us-ascii?Q?kZRUAehWf1XTmMlCwSPTxLK227B/b8brn8pK6FRI?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: h64PBBcqOmy2AL6DdOJA2tPgcFgiMGvQW1soMfg8ZjY6HGlGR9Qm9dxYiCbe9LNFnjl5JiSXwwlkxdg5qNMVfhyF27pWHvQkGb5MeFq7SveaYlLWyD+cEuTxB6DAj83XrC+m/VKM9orKvNNQuITmifX1ppQ4li3ApR1XKL25UGZ1P3095MOPxL1EdVk8GGCYqRMTXCgbyLalrMtAiABBjguTRTblmU76qbdIjqBMB/Zw2JbRu8tR73Y6r6qYBPgid8jfKY55h4HpqhyD6UkvNE0ECoJ/Zxnlst9weyHYjDsuJ6NCM53kXsMm+ThXQUX/JFfQNC1dNiw5yWFVBzx0FcNxwNkI6LdEIlqJD/SLrpdBOKw08U9glcQEGiIVZfZExN6Z+ZHo1FRtDwbnyo/xTTxzX532fpoHXIHHNpxFeN4prq15sXnVrsqCCXmgt7jprngO7umGf1mP+iFQmteUnhk9ySsZHeLeyfw2xxIAzkjmqkglk+BkXhIva7gfTQxFV26xWJStkab/bTuCsa94xlPvfLAKy48Yxif3xkBVfBhu/cVXkxVNyvCYLgpAACcprOc+DL8mqMaS47RMK8Bi/shueodLwPx6KIIr8nCnI/5vjCmlSTo8SdLw5q3YgK1LepEjreSnL3Ml3dZ7bzGWVNbsGgzMK/kbPAg+0ntNfX0=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9648512f-ba6c-42b1-2ebf-08dc8b3b5d2c
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Jun 2024 23:57:06.1913 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: KLu/oTRpkaGZjcNpmZ9QaHAQsmdiQbsHwJkMmXSorV/5OayqXTpeJbW7lbSvc4aZ
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MW4PR19MB5565
X-BESS-ID: 1718236630-104402-12771-12298-1
X-BESS-VER: 2019.1_20240612.1610
X-BESS-Apparent-Source-IP: 104.47.56.40
X-BESS-Parts: H4sIAAAAAAACAz2MMQ6EMAwE/+Kawkkcm/AVdEXiOKJBFJfiJMTfLwXQrEYjza
 4n2K/DAn3sBMcXFhaWQduQ2ThblWTG5ExUJbaIktgFDDNFuKan3/p+956S8+9B0Rpy8s
 0xKlZFIhPDQrO04g2uzx9YyqsiggAAAA==
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.256912 [from 
 cloudscan16-231.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] [External] : Re: Inquiry Regarding Checksum
 Support for Lustre Extended Attributes
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
Reply-To: Andreas Dilger <adilger@whamcloud.com>
Cc: lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============2820183533458085273=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2820183533458085273==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_AE0CD2DB6E8447278D824C1B06BBF627whamcloudcom_"

--_000_AE0CD2DB6E8447278D824C1B06BBF627whamcloudcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Jun 12, 2024, at 16:54, Patrick Farrell <patrick.farrell@oracle.com<mail=
to:patrick.farrell@oracle.com>> wrote:

A few clarifying questions, partly for me and hopefully for Saisha as well =
as a non-Lustre expert.  The ldiskfs file system supported for Lustre disk =
targets is a modified ext4, so it inherits ext4 features for the local volu=
me, but not all of them are supported for ldiskfs formatted volumes.  So do=
es Lustre support use of metadata_csum (that's the relevant option, isn't i=
t?) when formatting ldiskfs?  Is it on by default?

I _thought_ that xattrs have had built-in checksums since they were first a=
dded to ext3, long before metadata_csum existed.  However, looking at the m=
etadata_csum patch handling xattrs, I see that it is adding the 'h_checksum=
' field itself.  I guess I was conflating the xattr *checksum* with the xat=
tr *hash* which is used for xattr block sharing, but is never actually veri=
fied by the kernel.

Inferring from your comments, I think you're saying metadata_csums are (or =
can be) used on an ldiskfs volume.  But since they are just a local disk fe=
ature, they contribute only minimally to resiliency in Lustre, and Lustre m=
akes no use of them.  They can help protect against some damage to the loca=
l volume, but Lustre is unaware of them.

Unfortunately, the Lustre "dirdata" feature did not previously interoperate=
 well with metadata_csum (which was developed many years later), so current=
ly mkfs.lustre explicitly disables the metadata_csum feature when the files=
ystem is formatted.  There have been incremental fixes related to dirdata a=
nd metadata_csum over the years, so it is possible that these would work to=
gether today, but it has not been on anyone's radar to test and verify that=
 these features are OK to use together.  https://jira.whamcloud.com/browse/=
LU-13650 is open to track this, maybe someone would be interested to work o=
n that...

Do the metadata checksums extend to all ext4/ldiskfs extended attributes?  =
Are they done separately for individual xattrs or just for the whole inode?

There is an h_checksum field for the xattr header that covers all of the xa=
ttrs, but only the e_hash field for the individual entry:

struct ext4_xattr_header {
        __le32  h_magic;        /* magic number for identification */
        __le32  h_refcount;     /* reference count */
        __le32  h_blocks;       /* number of disk blocks used */
        __le32  h_hash;         /* hash value of all attributes */
        __le32  h_checksum;     /* crc32c(uuid+id+xattrblock) */
                                /* id =3D inum if refcount=3D1, blknum othe=
rwise */
        __u32   h_reserved[3];  /* zero right now */
};

struct ext4_xattr_entry {
        __u8    e_name_len;     /* length of name */
        __u8    e_name_index;   /* attribute name index */
        __le16  e_value_offs;   /* offset in disk block of value */
        __le32  e_value_block;  /* disk block attribute is stored on (n/i) =
*/
        __le32  e_value_size;   /* size of attribute value */
        __le32  e_hash;         /* hash value of name and value */
        char    e_name[0];      /* attribute name */
};

The kernel wiki describes a possible implementation that credits someone na=
med 'Andreas Dilger' ( :) ) with suggesting checksumming them under the ino=
de checksum rather than separately, but I don't know what was actually impl=
emented.

I think that was for xattrs stored within the inode itself, since in-inode =
xattrs do not have the "ext4_xattr_header" that is used in external xattr b=
locks, but apparently you can't trust everything that guy writes... :-)  Th=
anks for keeping me honest.

Cheers, Andreas


Regards,
Patrick
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org<mailto:lustre-dev=
el-bounces@lists.lustre.org>> on behalf of Andreas Dilger via lustre-devel =
<lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>>
Sent: Wednesday, June 12, 2024 5:27 PM
To: Saisha Kamat <skamat1@charlotte.edu<mailto:skamat1@charlotte.edu>>
Cc: lustre-devel <lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.l=
ustre.org>>
Subject: [External] : Re: [lustre-devel] Inquiry Regarding Checksum Support=
 for Lustre Extended Attributes

On Jun 12, 2024, at 12:35, Saisha Kamat via lustre-devel <lustre-devel@list=
s.lustre.org<mailto:lustre-devel@lists.lustre.org>> wrote:

Hello,

I hope this email finds you well.

My name is Saisha, and I am currently pursuing my Ph.D. at UNC-Charlotte, w=
ith a focus on research related to the Lustre File System. As part of my pr=
oject, I am exploring the possibility of utilizing checksums to verify Lust=
re extended attributes.

My understanding is that the ext4 file system supports checksums for extend=
ed attributes (xattrs). However, I am interested in whether this functional=
ity extends to Lustre as well.

Yes, the ext4 (and ZFS) xattr values have checksums.  No, the xattr checksu=
ms are neither managed or verified by Lustre, and only come into effect whe=
n they are passed on to the backing filesystem.  Conceivably, it would be p=
ossible to have a checksum (e.g. crc32c) for the xattr values in the MDS_GE=
TXATTR and MDS_SETXATTR RPCs, if this is something you are interested to co=
ntribute.

This could probably be done by overloading one of the 32-bit fields in the =
mdt_body for getxattr, and one in mdt_rec_reint for setxattr, but there is =
also "opportunistic" xattr prefetching done in the lookup RPC, so that woul=
d need to be covered as well.

Also, the checksum would also need to be kept with the xattrs in cache and =
verified on access, otherwise they could become corrupted in memory after t=
he RPC processing had completed.

Finally, there is no interface to specify or verify the xattr checksum in t=
he syscall interface, so there can be no guarantee that the data supplied i=
n the setxattr is correct, or remains correct after supplied to getxattr, b=
ut the window there is very small.

Cheers, Andreas

I would greatly appreciate it if you could provide some insights or direct =
me to relevant documentation on this matter. Any information or guidance yo=
u can offer would be invaluable to my research.

Thank you very much for your time and assistance.

Thanks and Regards,
Saisha
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org<https://urldef=
ense.com/v3/__http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org_=
_;!!ACWV5N9M2RV99hQ!NxZsGb9nGU3ZLJa1pn9PclSTh2QUuTOnSdBLFvT4cYZxHl-jq2z3TrA=
RWnu9vlkaS-diipwr7e73a1J0pgTw4Htt05quzd0a$>

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud








--_000_AE0CD2DB6E8447278D824C1B06BBF627whamcloudcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <D6A657D96B723C4280B303ACA943A53E@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Jun 12, 2024, at 16:54, Patrick Farrell &lt;<a href=3D"mailto:patrick.fa=
rrell@oracle.com" class=3D"">patrick.farrell@oracle.com</a>&gt; wrote:<br c=
lass=3D"">
<div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div style=3D"font-style: normal; font-variant-caps: normal; font-weight: n=
ormal; letter-spacing: normal; text-align: start; text-indent: 0px; text-tr=
ansform: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-=
width: 0px; text-decoration: none; font-family: Aptos, Aptos_EmbeddedFont, =
Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt;" clas=
s=3D"">
<br class=3D"">
</div>
<div class=3D"elementToProof" style=3D"font-style: normal; font-variant-cap=
s: normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; word-spacing: =
0px; -webkit-text-stroke-width: 0px; text-decoration: none; font-family: Ap=
tos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-seri=
f; font-size: 12pt;">
A few clarifying questions, partly for me and hopefully for Saisha as well =
as a non-Lustre expert.&nbsp; The ldiskfs file system supported for Lustre =
disk targets is a modified ext4, so it inherits ext4 features for the local=
 volume, but not all of them are supported
 for ldiskfs formatted volumes.&nbsp; So does Lustre support use of metadat=
a_csum (that's the relevant option, isn't it?) when formatting ldiskfs?&nbs=
p; Is it on by default?</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
I _thought_ that xattrs have had built-in checksums since they were first a=
dded to ext3, long before metadata_csum existed. &nbsp;However, looking at =
the metadata_csum patch handling xattrs, I see that it is adding the 'h_che=
cksum' field itself. &nbsp;I guess I was conflating
 the xattr *checksum* with the xattr *hash* which is used for xattr block s=
haring, but is never actually verified by the kernel.&nbsp;</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"elementToProof" style=3D"font-style: normal; font-variant-cap=
s: normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; word-spacing: =
0px; -webkit-text-stroke-width: 0px; text-decoration: none; font-family: Ap=
tos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-seri=
f; font-size: 12pt;">
Inferring from your comments, I think you're saying metadata_csums are (or =
can be) used on an ldiskfs volume.&nbsp; But since they are just a local di=
sk feature, they contribute only minimally to resiliency in Lustre, and Lus=
tre makes no use of them.&nbsp; They can help
 protect against some damage to the local volume, but Lustre is unaware of =
them.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
Unfortunately, the Lustre &quot;dirdata&quot; feature did not previously in=
teroperate well with metadata_csum (which was developed many years later), =
so currently mkfs.lustre explicitly disables the metadata_csum feature when=
 the filesystem is formatted. &nbsp;There have
 been incremental fixes related to dirdata and metadata_csum over the years=
, so it is possible that these would work together today, but it has not be=
en on anyone's radar to test and verify that these features are OK to use t=
ogether. &nbsp;<a href=3D"https://jira.whamcloud.com/browse/LU-13650" class=
=3D"">https://jira.whamcloud.com/browse/LU-13650</a>&nbsp;is
 open to track this, maybe someone would be interested to work on that...</=
div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"elementToProof" style=3D"font-style: normal; font-variant-cap=
s: normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; word-spacing: =
0px; -webkit-text-stroke-width: 0px; text-decoration: none; font-family: Ap=
tos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-seri=
f; font-size: 12pt;">
Do the metadata checksums extend to all ext4/ldiskfs extended attributes?&n=
bsp; Are they done separately for individual xattrs or just for the whole i=
node?</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
<div>There is an h_checksum field for the xattr header that covers all of t=
he xattrs, but only the e_hash field for the individual entry:</div>
<div><br class=3D"">
</div>
<div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgba(242, 242, 242, 0.901961); background-color: rgb=
a(0, 0, 0, 0.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures; color: #2fb41d"=
 class=3D"">struct</span><span style=3D"font-variant-ligatures: no-common-l=
igatures" class=3D""> ext4_xattr_header {</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgb(46, 174, 187); background-color: rgba(0, 0, 0, 0=
.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures; color: rgba(242=
, 242, 242, 0.9)" class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; __le32&nbsp; h_mag=
ic;&nbsp; &nbsp; &nbsp; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">/* magic number for identification */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgba(242, 242, 242, 0.901961); background-color: rgb=
a(0, 0, 0, 0.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbs=
p; &nbsp; &nbsp; &nbsp; __le32&nbsp; h_refcount; &nbsp; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures; color: #=
2eaebb" class=3D"">/* reference count */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgba(242, 242, 242, 0.901961); background-color: rgb=
a(0, 0, 0, 0.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbs=
p; &nbsp; &nbsp; &nbsp; __le32&nbsp; h_blocks; &nbsp; &nbsp; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures; color: #=
2eaebb" class=3D"">/* number of disk blocks used */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgb(46, 174, 187); background-color: rgba(0, 0, 0, 0=
.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures; color: rgba(242=
, 242, 242, 0.9)" class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; __le32&nbsp; h_has=
h; &nbsp; &nbsp; &nbsp; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">/* hash value of all attributes */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgba(242, 242, 242, 0.901961); background-color: rgb=
a(0, 0, 0, 0.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbs=
p; &nbsp; &nbsp; &nbsp; __le32&nbsp; h_checksum; &nbsp; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures; color: #=
2eaebb" class=3D"">/* crc32c(uuid+id+xattrblock) */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgb(46, 174, 187); background-color: rgba(0, 0, 0, 0=
.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures; color: rgba(242=
, 242, 242, 0.9)" class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbs=
p; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">/* id =3D inum if refcount=3D1, blknum otherwise */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgba(242, 242, 242, 0.901961); background-color: rgb=
a(0, 0, 0, 0.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbs=
p; &nbsp; &nbsp; &nbsp; __u32 &nbsp; h_reserved[</span><span style=3D"font-=
variant-ligatures: no-common-ligatures; color: #b42419" class=3D"">3</span>=
<span style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">];&n=
bsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures; color: #=
2eaebb" class=3D"">/* zero right now */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgba(242, 242, 242, 0.901961); background-color: rgb=
a(0, 0, 0, 0.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">};</=
span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgba(242, 242, 242, 0.901961); background-color: rgb=
a(0, 0, 0, 0.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures" class=3D""><br =
class=3D"">
</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; font-=
family: Monaco; color: rgba(242, 242, 242, 0.901961); background-color: rgb=
a(0, 0, 0, 0.862745);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal;" clas=
s=3D""><span style=3D"font-variant-ligatures: no-common-ligatures; color: #=
2fb41d" class=3D"">struct</span><span style=3D"font-variant-ligatures: no-c=
ommon-ligatures" class=3D""> ext4_xattr_entry
 {</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal;" clas=
s=3D""><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">&nbsp; &nbsp; &nbsp; &nbsp; __u8&nbsp; &nbsp; e_name_len; &nbsp; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures; color: #=
2eaebb" class=3D"">/* length of name */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal;" clas=
s=3D""><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">&nbsp; &nbsp; &nbsp; &nbsp; __u8&nbsp; &nbsp; e_name_index; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures; color: #=
2eaebb" class=3D"">/* attribute name index */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; color=
: rgb(46, 174, 187);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures; color: rgba(242=
, 242, 242, 0.9)" class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; __le16&nbsp; e_val=
ue_offs; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">/* offset in disk block of value */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; color=
: rgb(46, 174, 187);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures; color: rgba(242=
, 242, 242, 0.9)" class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; __le32&nbsp; e_val=
ue_block;&nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">/* disk block attribute is stored on (n/i) */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal;" clas=
s=3D""><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">&nbsp; &nbsp; &nbsp; &nbsp; __le32&nbsp; e_value_size; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures; color: #=
2eaebb" class=3D"">/* size of attribute value */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal; color=
: rgb(46, 174, 187);" class=3D"">
<span style=3D"font-variant-ligatures: no-common-ligatures; color: rgba(242=
, 242, 242, 0.9)" class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; __le32&nbsp; e_has=
h; &nbsp; &nbsp; &nbsp; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">/* hash value of name and value */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal;" clas=
s=3D""><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">&nbsp; &nbsp; &nbsp; &nbsp;
</span><span style=3D"font-variant-ligatures: no-common-ligatures; color: #=
2fb41d" class=3D"">char</span><span style=3D"font-variant-ligatures: no-com=
mon-ligatures" class=3D"">&nbsp; &nbsp; e_name[</span><span style=3D"font-v=
ariant-ligatures: no-common-ligatures; color: #b42419" class=3D"">0</span><=
span style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">];&nb=
sp;
 &nbsp; &nbsp; </span><span style=3D"font-variant-ligatures: no-common-liga=
tures; color: #2eaebb" class=3D"">/* attribute name */</span></div>
<div style=3D"margin: 0px; font-stretch: normal; line-height: normal;" clas=
s=3D""><span style=3D"font-variant-ligatures: no-common-ligatures" class=3D=
"">};</span></div>
</span></div>
</div>
<br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"elementToProof" style=3D"font-style: normal; font-variant-cap=
s: normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; word-spacing: =
0px; -webkit-text-stroke-width: 0px; text-decoration: none; font-family: Ap=
tos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-seri=
f; font-size: 12pt;">
The kernel wiki describes a possible implementation that credits someone na=
med 'Andreas Dilger' ( :) ) with suggesting checksumming them under the ino=
de checksum rather than separately, but I don't know what was actually impl=
emented.</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
I think that was for xattrs stored within the inode itself, since in-inode =
xattrs do not have the &quot;ext4_xattr_header&quot; that is used in extern=
al xattr blocks, but apparently you can't trust everything that guy writes.=
.. :-) &nbsp;Thanks for keeping me honest.</div>
<div><br class=3D"">
</div>
<div>Cheers, Andreas</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"elementToProof" style=3D"font-style: normal; font-variant-cap=
s: normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; word-spacing: =
0px; -webkit-text-stroke-width: 0px; text-decoration: none; font-family: Ap=
tos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-seri=
f; font-size: 12pt;">
<br class=3D"">
Regards,</div>
<div class=3D"elementToProof" style=3D"font-style: normal; font-variant-cap=
s: normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; word-spacing: =
0px; -webkit-text-stroke-width: 0px; text-decoration: none; font-family: Ap=
tos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-seri=
f; font-size: 12pt;">
Patrick</div>
<div id=3D"appendonsend" style=3D"caret-color: rgb(0, 0, 0); font-family: H=
elvetica; font-size: 14px; font-style: normal; font-variant-caps: normal; f=
ont-weight: normal; letter-spacing: normal; text-align: start; text-indent:=
 0px; text-transform: none; white-space: normal; word-spacing: 0px; -webkit=
-text-stroke-width: 0px; text-decoration: none;" class=3D"">
</div>
<hr tabindex=3D"-1" style=3D"caret-color: rgb(0, 0, 0); font-family: Helvet=
ica; font-size: 14px; font-style: normal; font-variant-caps: normal; font-w=
eight: normal; letter-spacing: normal; text-align: start; text-indent: 0px;=
 text-transform: none; white-space: normal; word-spacing: 0px; -webkit-text=
-stroke-width: 0px; text-decoration: none; display: inline-block; width: 12=
88.6875px;" class=3D"">
<span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size=
: 14px; font-style: normal; font-variant-caps: normal; font-weight: normal;=
 letter-spacing: normal; text-align: start; text-indent: 0px; text-transfor=
m: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width:=
 0px; text-decoration: none; float: none; display: inline !important;" clas=
s=3D""></span>
<div id=3D"divRplyFwdMsg" dir=3D"ltr" style=3D"caret-color: rgb(0, 0, 0); f=
ont-family: Helvetica; font-size: 14px; font-style: normal; font-variant-ca=
ps: normal; font-weight: normal; letter-spacing: normal; text-align: start;=
 text-indent: 0px; text-transform: none; white-space: normal; word-spacing:=
 0px; -webkit-text-stroke-width: 0px; text-decoration: none;" class=3D"">
<font face=3D"Calibri, sans-serif" style=3D"font-size: 11pt;" class=3D""><b=
 class=3D"">From:</b><span class=3D"Apple-converted-space">&nbsp;</span>lus=
tre-devel &lt;<a href=3D"mailto:lustre-devel-bounces@lists.lustre.org" clas=
s=3D"">lustre-devel-bounces@lists.lustre.org</a>&gt; on behalf
 of Andreas Dilger via lustre-devel &lt;<a href=3D"mailto:lustre-devel@list=
s.lustre.org" class=3D"">lustre-devel@lists.lustre.org</a>&gt;<br class=3D"=
">
<b class=3D"">Sent:</b><span class=3D"Apple-converted-space">&nbsp;</span>W=
ednesday, June 12, 2024 5:27 PM<br class=3D"">
<b class=3D"">To:</b><span class=3D"Apple-converted-space">&nbsp;</span>Sai=
sha Kamat &lt;<a href=3D"mailto:skamat1@charlotte.edu" class=3D"">skamat1@c=
harlotte.edu</a>&gt;<br class=3D"">
<b class=3D"">Cc:</b><span class=3D"Apple-converted-space">&nbsp;</span>lus=
tre-devel &lt;<a href=3D"mailto:lustre-devel@lists.lustre.org" class=3D"">l=
ustre-devel@lists.lustre.org</a>&gt;<br class=3D"">
<b class=3D"">Subject:</b><span class=3D"Apple-converted-space">&nbsp;</spa=
n>[External] : Re: [lustre-devel] Inquiry Regarding Checksum Support for Lu=
stre Extended Attributes</font>
<div class=3D"">&nbsp;</div>
</div>
<div class=3D"" style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica;=
 font-size: 14px; font-style: normal; font-variant-caps: normal; font-weigh=
t: normal; letter-spacing: normal; text-align: start; text-indent: 0px; tex=
t-transform: none; white-space: normal; word-spacing: 0px; -webkit-text-str=
oke-width: 0px; text-decoration: none; word-wrap: break-word; line-break: a=
fter-white-space;">
On Jun 12, 2024, at 12:35, Saisha Kamat via lustre-devel &lt;<a href=3D"mai=
lto:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@lists.lustre.org=
</a>&gt; wrote:<br class=3D"">
<div class=3D"">
<blockquote type=3D"cite" class=3D""><br class=3D"x_Apple-interchange-newli=
ne">
<div class=3D"">
<div dir=3D"ltr" class=3D"">Hello,<br class=3D"">
<br class=3D"">
I hope this email finds you well.<br class=3D"">
<br class=3D"">
My name is Saisha, and I am currently pursuing my Ph.D. at UNC-Charlotte, w=
ith a focus on research related to the Lustre File System. As part of my pr=
oject, I am exploring the possibility of utilizing checksums to verify Lust=
re extended attributes.<br class=3D"">
<br class=3D"">
My understanding is that the ext4 file system supports checksums for extend=
ed attributes (xattrs). However, I am interested in whether this functional=
ity extends to Lustre as well.<br class=3D"">
</div>
</div>
</blockquote>
<div class=3D""><br class=3D"">
</div>
Yes, the ext4 (and ZFS) xattr values have checksums. &nbsp;No, the xattr ch=
ecksums are neither managed or verified by Lustre, and only come into effec=
t when they are passed on to the backing filesystem. &nbsp;Conceivably, it =
would be possible to have a checksum (e.g.
 crc32c) for the xattr values in the MDS_GETXATTR and MDS_SETXATTR RPCs, if=
 this is something you are interested to contribute.</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">This could probably be done by overloading one of the 32-bi=
t fields in the mdt_body for getxattr, and one in mdt_rec_reint for setxatt=
r, but there is also &quot;opportunistic&quot; xattr prefetching done in th=
e lookup RPC, so that would need to be covered
 as well.</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Also, the checksum would also need to be kept with the xatt=
rs in cache and verified on access, otherwise they could become corrupted i=
n memory after the RPC processing had completed.</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Finally, there is no interface to specify or verify the xat=
tr checksum in the syscall interface, so there can be no guarantee that the=
 data supplied in the setxattr is correct, or remains correct after supplie=
d to getxattr, but the window there
 is very small.</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Cheers, Andreas</div>
<div class=3D""><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div dir=3D"ltr" class=3D"">I would greatly appreciate it if you could prov=
ide some insights or direct me to relevant documentation on this matter. An=
y information or guidance you can offer would be invaluable to my research.=
<br class=3D"">
<br class=3D"">
Thank you very much for your time and assistance.
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Thanks and Regards,</div>
<div class=3D"">Saisha</div>
</div>
_______________________________________________<br class=3D"">
lustre-devel mailing list<br class=3D"">
<a href=3D"mailto:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@li=
sts.lustre.org</a><br class=3D"">
<a href=3D"https://urldefense.com/v3/__http://lists.lustre.org/listinfo.cgi=
/lustre-devel-lustre.org__;!!ACWV5N9M2RV99hQ!NxZsGb9nGU3ZLJa1pn9PclSTh2QUuT=
OnSdBLFvT4cYZxHl-jq2z3TrARWnu9vlkaS-diipwr7e73a1J0pgTw4Htt05quzd0a$" class=
=3D"">http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org</a><br c=
lass=3D"">
</div>
</blockquote>
</div>
<br class=3D"">
<div class=3D"">
<div dir=3D"auto" class=3D"" style=3D"letter-spacing: normal; text-align: s=
tart; text-indent: 0px; text-transform: none; white-space: normal; word-spa=
cing: 0px; text-decoration: none; word-wrap: break-word; line-break: after-=
white-space;">
<div dir=3D"auto" class=3D"" style=3D"letter-spacing: normal; text-align: s=
tart; text-indent: 0px; text-transform: none; white-space: normal; word-spa=
cing: 0px; text-decoration: none; word-wrap: break-word; line-break: after-=
white-space;">
<div dir=3D"auto" class=3D"" style=3D"letter-spacing: normal; text-align: s=
tart; text-indent: 0px; text-transform: none; white-space: normal; word-spa=
cing: 0px; text-decoration: none; word-wrap: break-word; line-break: after-=
white-space;">
<div dir=3D"auto" class=3D"" style=3D"letter-spacing: normal; text-align: s=
tart; text-indent: 0px; text-transform: none; white-space: normal; word-spa=
cing: 0px; text-decoration: none; word-wrap: break-word; line-break: after-=
white-space;">
<div dir=3D"auto" class=3D"" style=3D"letter-spacing: normal; text-align: s=
tart; text-indent: 0px; text-transform: none; white-space: normal; word-spa=
cing: 0px; text-decoration: none; word-wrap: break-word; line-break: after-=
white-space;">
<div dir=3D"auto" class=3D"" style=3D"letter-spacing: normal; text-align: s=
tart; text-indent: 0px; text-transform: none; white-space: normal; word-spa=
cing: 0px; text-decoration: none; word-wrap: break-word; line-break: after-=
white-space;">
<div class=3D"">Cheers, Andreas</div>
<div class=3D"">--</div>
<div class=3D"">Andreas Dilger</div>
<div class=3D"">Lustre&nbsp;Principal Architect</div>
<div class=3D"">Whamcloud</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
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
</body>
</html>

--_000_AE0CD2DB6E8447278D824C1B06BBF627whamcloudcom_--

--===============2820183533458085273==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2820183533458085273==--
