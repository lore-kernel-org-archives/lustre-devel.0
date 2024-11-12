Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2AD2ED597AA
	for <lustre-devel@archiver.kernel.org>; Tue, 12 Nov 2024 21:45:35 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Xp0Mc19p7z1x7g;
	Tue, 12 Nov 2024 13:45:32 -0800 (PST)
Received: from mx0f-00689501.gpphosted.com (mx0f-00689501.gpphosted.com
 [67.231.155.186])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Xp0MZ0X6yz1wgM
 for <lustre-devel@lists.lustre.org>; Tue, 12 Nov 2024 13:45:29 -0800 (PST)
Received: from pps.filterd (m0329784.ppops.net [127.0.0.1])
 by mx0e-00689501.gpphosted.com (8.18.1.2/8.18.1.2) with ESMTP id
 4ACGWi8A020941; Tue, 12 Nov 2024 21:45:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ornl.gov;
 h=from : to : subject :
 date : message-id : references : in-reply-to : content-type : content-id :
 content-transfer-encoding : mime-version; s=pp1;
 bh=q/svpJdU5GtQyZFo/Gmo3izv4gDQ4ybmJsXiJB2MOqw=;
 b=MVHUyawad5pgG7j1lttr9jCd5cpIn5+nM1a9bI1fpO6HD++w0vuNDzA0h4lnkgHEG09j
 6i1+7LrGkGYlrkykFt8pvNGb2tGUVuv8XMGol30+jaSvR3YHbOvH9qCbcmTwuyJwyEXf
 DdZFczHsqnUsbrH4ZZfxVcBMrs/4LRhhfr5lArd86HD32Eu+SJ9t5cw9REIAXWdKZdf3
 3WC1JGMy+lWXUuCab1qF2xssW2kc2x1UeZkA4Z1Et/h4y2Mdva4qLilpT/d9m9oAojXe
 84bjnKXojuLTzboy/7nOx9/8WvM0mcXr2TqLzRqUzJoITL3tdH0MdcaRG5YBzcyBSFxJ hg== 
Received: from emgwy2.ornl.gov ([160.91.254.10])
 by mx0e-00689501.gpphosted.com (PPS) with ESMTPS id 42t0k7ff24-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
 Tue, 12 Nov 2024 21:45:28 +0000
Received: from exchhy03.ornl.gov (exchhy03.ornl.gov [128.219.12.142])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by emgwy2.ornl.gov (Postfix) with ESMTPS id 4Xp0MW5CQGzyjK;
 Tue, 12 Nov 2024 16:45:27 -0500 (EST)
Received: from exchhy01.ornl.gov (128.219.12.157) by exchhy03.ornl.gov
 (128.219.12.142) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1544.11; Tue, 12 Nov
 2024 16:45:27 -0500
Received: from SA9PR09CU002.outbound.protection.outlook.com (160.91.94.95) by
 exchhy01.ornl.gov (128.219.12.157) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1544.11 via Frontend Transport; Tue, 12 Nov 2024 16:45:27 -0500
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=lOGlpUlcnCAdAIWBTSBZh2BXaLKdAgwwElzybLb/AgcBzPzI9p2HyAAXy3Z4Eqr/Oyqtko3VOaGRdiuBxN4n7PkIlQQTMcXg0dxOOgwc9oSyNDukZ7yOyENWs/5p+KH9ThedKan1LYEHyHFjX0zik/c3HssRQu9ZPJgqQfYNQWODid0EnVcqlhSJKxp/qPLD4GPIipyS4OvMCkaXQqufFvxP4zX3OBh4MESr5Tmn3ioivpyyJAA2wvDIem2i1w+jyVpP+9ZTToVPvcGS1Q8F1kmWYvp7MxbsKJOYzaCX5oGh2EYeUYQ7R8HePN3fX4wTylCYhVaYNJLit+3NSbDJFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=q/svpJdU5GtQyZFo/Gmo3izv4gDQ4ybmJsXiJB2MOqw=;
 b=OGCI0WAOmNOspVByLfUHYZY6U4fq8+Lq4H7sKwlq0uSMcpbmQq4UZsl9qIIKvgircEAAdtN0xzxz+7ZBcWx+ucH1/mrBg34Y/3sa6SBgEiPMvlYQJba4+0Zo7MU3CgX3seDIGKNoB+wdJlz2mZZztrXrl0yhU83S3SEixWZ26HnN8BKdjPp31nBCmkfjckchG/bGfDJiQzp6ZmnNgBtaSPZP7GOpTwHJKOpxCfXh4jPo4Z7gk+KZcDWwmXXGGiUyea6w+ZusHzL3sYWan71PBtrF1ZCqUL5ZDXxMPLnL3D2j5OtUrB2MASJ51qj9OLjg44vkxVLU/w13Y9TlEu6GQA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ornl.gov; dmarc=pass action=none header.from=ornl.gov;
 dkim=pass header.d=ornl.gov; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ornl.gov; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=q/svpJdU5GtQyZFo/Gmo3izv4gDQ4ybmJsXiJB2MOqw=;
 b=g7Pu2c3nJnD5YtYrKzVJoScMLtuLJ4pc6FcE8k6yeAR76wU8kgQAIZbMK1JGLaQDoibT2dZo9KD3yHExIeTH3vj585Egd6nixH/DjFOis5rP6wtNKNd0JDQ+Kqca+AZgUAB5X7oAtGK962i+zwgXePLp8akjkSa33ifSTFGYdYM=
Received: from DM6PR09MB4647.namprd09.prod.outlook.com (2603:10b6:5:270::16)
 by BY5PR09MB4819.namprd09.prod.outlook.com (2603:10b6:a03:24b::18) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8158.17; Tue, 12 Nov
 2024 21:45:21 +0000
Received: from DM6PR09MB4647.namprd09.prod.outlook.com
 ([fe80::6999:c8c6:7170:3a5]) by DM6PR09MB4647.namprd09.prod.outlook.com
 ([fe80::6999:c8c6:7170:3a5%6]) with mapi id 15.20.8158.013; Tue, 12 Nov 2024
 21:45:21 +0000
From: "Mohr, Rick" <mohrrf@ornl.gov>
To: Else Someone <else@someonex.net>, "lustre-devel@lists.lustre.org"
 <lustre-devel@lists.lustre.org>
Thread-Topic: [EXTERNAL] [lustre-devel] mke2fs supported features: dirdata
Thread-Index: AQHbMw0x5IgahFkg3UGKChSBYae9F7Kz3moA
Date: Tue, 12 Nov 2024 21:45:21 +0000
Message-ID: <AC614B6D-D890-45FF-93DE-FD6387581EA0@ornl.gov>
References: <435e4ec8-35b7-4a23-8924-70607d90d654@someonex.net>
In-Reply-To: <435e4ec8-35b7-4a23-8924-70607d90d654@someonex.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/16.90.24110120
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM6PR09MB4647:EE_|BY5PR09MB4819:EE_
x-ms-office365-filtering-correlation-id: 03ba9390-1065-48ce-dfb7-08dd03634e8b
x-ld-processed: db3dbd43-4c4b-4544-9f8a-0553f9f5f25e,ExtAddr
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|1800799024|366016|10070799003|38070700018; 
x-microsoft-antispam-message-info: =?utf-8?B?WHFDZjdpVHVNWWxKZ1QzZnlaTmZxQ0Y4czYvOTd0Qkxud0NnYjhtSk5XdzJG?=
 =?utf-8?B?T2JJZmg5SkZrRzFBZ0lBTlFtMTVHNFhLVDdEdGI1VWFxV2lzbU1zM24rYnR1?=
 =?utf-8?B?MWRqSnR5MUFLU2FCVEpDQmxiQXYvZlB4UisrRTZOMEszcFhEZXU0K2kvTytP?=
 =?utf-8?B?ZlQ5SnphdHQ4ODJMMnN0V2hJNUtwb2x6eldSVjFUK3lmUnBKUEMwS3g4SHI0?=
 =?utf-8?B?a0ptODJnRG11bk83emJSbzlDcnY1YVhUNno4OW9UMVZCVGs2Wm1rTlJtU0ZQ?=
 =?utf-8?B?RmZScTZBYk0xd3krc0p3VEJwUTdqeldaSlNXaEFBTE45TlI0OGRJZGVOdHFo?=
 =?utf-8?B?djJLZ1R6aEI0MTBVSnhoSDJGU2hkaFdZRTI0bTFqNWpFdW5HaExtOVY4M2t3?=
 =?utf-8?B?aGE3V1Zpb2RpR1IzNHBaOUJzVWtKT2cwd2ltU0YyZUp5WG9nQXF3bGdPMkJY?=
 =?utf-8?B?QWNVNzQrSzRtNjFOYmQyaU83eFVBTkVjblUvaVpYcyt4Zlh3MzcwMzVNMlJy?=
 =?utf-8?B?dHdwMEVobDBDdlhDeXRwYUlEQ05GSlY2SU5MbFdUY2NvcitScnl0OTY3Q1NL?=
 =?utf-8?B?QWVxN01pZlg3WWtXVzQwMi9QNjNBcXRiS0ZGWDR4M0gvRWhSNFFuWXpGTDN6?=
 =?utf-8?B?cEpxWUg1dlhpZUErakhuSlJwOUhhTDhWcDVtOTdEUjZDWm5BbTVZTmpvNHRG?=
 =?utf-8?B?VU9acjN6czhUdmJxZXoyZnoxMTdZelk1L0wwMFdSVXY2VmZybmNlbXAvYmho?=
 =?utf-8?B?dmN3WHlJdkR2ci9RMWlHOHN3R21kNDdkWlM0OWpJdTd1ZHlEU1FHYkNxaTJ3?=
 =?utf-8?B?SEJvNHd6NHlBZFkyQUFDVFRiVjVIVEVQa3ZTMytaZjU5WkpXRVJPNFNtNnVi?=
 =?utf-8?B?RnVqaGd1NXlyb3ZVRUhhaXVxdnhrVWZDeDM0alpJVS9oUTZVU3FWVmFuaTFG?=
 =?utf-8?B?dnR1OFhZVnRObmM3bXk0aFhyN0ZmdVN3SnVYcnN2WStmY3NVUmRkZnFKa3NR?=
 =?utf-8?B?Nm5OREVLQXpoOVBjMktqdDExUGhwLzFFL2xxU0tpUlpDcTJldFJnNXVQenh5?=
 =?utf-8?B?b1FuZDFObmxFRVo5Z1VOempFekVscDVSaVlkMW5MQTFzaFJGVWliRFFyeEZQ?=
 =?utf-8?B?VWVLM0dmZyticUF0Q3U3eXdoVURqTEdmOW5tRnF3WktncmpSdmkzYUpBb2hq?=
 =?utf-8?B?RjRyb3RMTUNPcVpFWXl3bTl4SkY3SWpzaEZtOXd4NkhPY0JZNFRxME03VGl6?=
 =?utf-8?B?Ui85QWJnMzBCK0YwKzhLUldmZkUvaGhyMTBDRE0xZ2VndHE0OVRsNHBXNVNP?=
 =?utf-8?B?ZXhuVE9sOFExWWJOV2pDZTZIcWZDMW5weGRJVllZZ1ZHOVJEZHVxdUpOTms5?=
 =?utf-8?B?QUtQcGNQWDZmTmVveGlELytEanJNY2pRNlpSYi9HM2VpODlTTDEwSHZlZHlO?=
 =?utf-8?B?cGJGYWtTUndrUHE3dC9SWlpuMFJYd1BoUlQzZmt6TVdjOVhPWmJKdXZHT3hr?=
 =?utf-8?B?Z0RDMDdSYXRGalpWcFBFdytwM25RWXJoZ3BrVm9qRkt0TWhwYndjN0pRN2dF?=
 =?utf-8?B?WUZlNVJEcUM2R3lpUUUwMlJ0ZWpWVC84NGROL0NlOExWUHBmSEo5V2d6a3V1?=
 =?utf-8?B?M3BZb01JK2ZrRmhOMDRrTUhwRHY2OVFwMU9pdUhaUnByMFlqMldJMlFCRy9l?=
 =?utf-8?B?OW1CRWc0RU1MTzV2OHVKOTRUdWl5VDFBUk9pbEdVRHFiQnREY2NSL1RTTzU2?=
 =?utf-8?Q?77H54tSrCNqsE0QsibvhqQzaxsHnLnLY74k8udx?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM6PR09MB4647.namprd09.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(366016)(10070799003)(38070700018); DIR:OUT;
 SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?RW5sSWNVMWk1dzNhMFRRN21GdDY3RTJWSll4N0E4bGcrcm54eGxFVnJGeVFk?=
 =?utf-8?B?Y01YZXFWeDZrMnN5SXA3QU1rVU1IVGVyaEpKMVJiMUExeW1Bb2Zac1RlVnVY?=
 =?utf-8?B?aXhYdi8xdU4rWUp2Q0cvQVd6NGhlVjhKQzlnSDQ1SGJPamFPbnZjSC91RStC?=
 =?utf-8?B?Nk96aG9vYjFWRU40SlJQRkNDNmptcmtsQlpTR2RwUXVqbGxlVzZKWlg4azlt?=
 =?utf-8?B?bVNkeEtxazJlc1F3ZDR5RHBVNDhlRE0vT0tOcGQyWVdxdlhpSkIwbTBFS2Ur?=
 =?utf-8?B?TDRwczIxdTVOUTVnWDlWcWVZcWdrMHVvYXo5OERiRGlhUkZSZnMwOXM0c0xZ?=
 =?utf-8?B?czRzU0hiejlYVDVhaWc2UlpTbENPQ0drYnh1akNnZ2RwVXJzc0ZxNDhTUE5o?=
 =?utf-8?B?U3hYK21hUU1rRDVpUWM0Z3RLQVlHemVEUmZUU3oxUTB2MnVwS21ZU09HNDds?=
 =?utf-8?B?bTM4NlJnSldhRzNIb3JKQ1JIYVVxWmhJQS95bU9Nek5MdXlCblNhUUxzclJp?=
 =?utf-8?B?N2FLaENTeXhIWWFFc3AxYmlRVzFWUEpYNkxjNVVuZ3JHWFphMG0rYUZDL0tx?=
 =?utf-8?B?SWtrbzFqYU1melNKWTZ5cHBUUVJGblNOQ2lUWkdzU3Zsc0RBN0hocklPSFJy?=
 =?utf-8?B?bWhYd1JOT2RvYW1OQUoxZjlxM1ZtVDlkR25ESHhnN2NYaVFWalMycGpVUkQv?=
 =?utf-8?B?S2VTNHFLWEVWNnNEb2lhMWh4SmREZ2FmazV6Y3hrWUFtb1duUUU2ak05ZHVY?=
 =?utf-8?B?TThnRnR2Q1RaaU80T21QUGNUamtiaDlaSkFOUkdSSGFkTDRwbVZGNlFIb09N?=
 =?utf-8?B?TklQTHFiaTdsY2MyZStKbW1QN1BWcDV3amtwQjgvdE5Zamw4aEZJMC9hMXJt?=
 =?utf-8?B?N1dNVkl4OUJxWUdFa2YwMzlOWitwTlk5SWU5Rk94dUQxMFY0Nll6d0FqT01q?=
 =?utf-8?B?bUZNdlBQZWs1RmU4Mml6MUNYcmJod3BCU0J6TVZBS3poelkwbmlpVGVacTM2?=
 =?utf-8?B?dzBOeXI5dmUrVnB0WE85dld0Um1jbzZTcll5bXB3SG1CalNoRnpTdjdtK0xR?=
 =?utf-8?B?ZWJFVDl0Rnh4ZWwyd0NISlpuQW5JVzZpVnJKQlVmNlY4ZU5aRHNUN2kwczdH?=
 =?utf-8?B?RGVOWjEzV1VKSFU2Qm1ldCtZMVFqckswNVIrbkMzcEJCWGRsV1F2em12eUFP?=
 =?utf-8?B?SVNWNGs3VWZGR2ZRYm5tZ1Y1VDVHTkpSYmdHdmpibE9UaWQwY1lxMENVYnVu?=
 =?utf-8?B?bmhxN29RWU53TWJjSHI1YTdzZUhOV0xjaFQyNmFJVGhqRVM5REo0VGFTcG9G?=
 =?utf-8?B?WTNTT3NYUmxqWkIveCtaNXFoZVZvcG9kTWRhMjBPUU9BNFJzMHlhKy9WUEtj?=
 =?utf-8?B?azdiM3ZQdlBwSVpESXplL3pNbXhGTjF6Q2gxanFMV21QSDc3VzdxaU9COUtI?=
 =?utf-8?B?K1ZmZ25ZY1RNZTEvVG1NN1hmR1VHKzdWejFrWFMxUmVaZnNDVlpZUGJvWmNu?=
 =?utf-8?B?NGM4M3RvQUtyTDRYZXlQdzFqdVQwamwyQStvT3VORk9VaDd5dWJseG5GWmg4?=
 =?utf-8?B?NVhsTitPOFlvaS80bFBKakVBbzZTemN5eUk0TE1OYWlTQ1FYSFo1SmNiYzlD?=
 =?utf-8?B?akpZK3Y0NnlRNW5LbW5sVkFGMmRuVUJJMyt6eEE3MEpMaU4xYXVqSEFrVDRD?=
 =?utf-8?B?VDlHNjZZT3N5Mndkb1hDNDJnalVQcXdMZmZkWTkvQm9acU4vZjFUYmtrY09L?=
 =?utf-8?B?OXgwWDdselVyOTdndU4vMGFBeDZwazVWekU0aERpL1FJb24rY29rSkZEMmdw?=
 =?utf-8?B?UUVHZjM3RHlCWkRVV25kMW1TRTZVN2gzMlJVVUFtV3JTSTdMTXRwNWdaK1gr?=
 =?utf-8?B?ak9SY01TTVo2aXR6Rmozay91QTBreHo3L3cvOVBWZ1czbnpMTjl5N2ozc3la?=
 =?utf-8?B?UGZsQm1YS3dGNWd1OE5ZcFI3dm9QNWdCSlY3VFBITzZMREJoY1UxUTJUMmhm?=
 =?utf-8?B?di81cnZOczZzTzExWTlianFFaWFpWVBzaGdVK1RQQzJMY09MYmN5Y2FuY0NW?=
 =?utf-8?B?azBnVWVickNUTkp1bStnOHpqYjEyemQyVkJ1c3dXNTNKSDVuR0xjWlYxcXNo?=
 =?utf-8?Q?qTdLfkEwRXOCxp7wEBvrzys4I?=
Content-ID: <9862DB1E2951B740975F0B39378043C0@namprd09.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM6PR09MB4647.namprd09.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 03ba9390-1065-48ce-dfb7-08dd03634e8b
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Nov 2024 21:45:21.0848 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: db3dbd43-4c4b-4544-9f8a-0553f9f5f25e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BY5PR09MB4819
X-OriginatorOrg: ornl.gov
X-Proofpoint-GUID: 6xXKeY4kuGG5bs1ezecrsim_g8MgVhLV
X-Proofpoint-ORIG-GUID: 6xXKeY4kuGG5bs1ezecrsim_g8MgVhLV
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1057,Hydra:6.0.680,FMLib:17.12.62.30
 definitions=2024-11-12_09,2024-11-12_02,2024-09-30_01
X-Proofpoint-Spam-Details: rule=oubound_notspam policy=oubound score=0
 adultscore=0 phishscore=0
 impostorscore=0 spamscore=0 bulkscore=0 lowpriorityscore=0 malwarescore=0
 mlxlogscore=999 clxscore=1011 priorityscore=1501 suspectscore=0 mlxscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2409260000
 definitions=main-2411120172
Subject: Re: [lustre-devel] [EXTERNAL]  mke2fs supported features: dirdata
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

RTJmc3Byb2dzIGRvZXMgcmVxdWlyZSBzb21lIHBhdGNoZXMuICBXaGFtY2xvdWQncyBzaXRlIGhh
cyBwYXRjaGVkIHZlcnNpb25zIGF2YWlsYWJsZSBmb3IgZG93bmxvYWQ6DQoNCmh0dHBzOi8vZG93
bmxvYWRzLndoYW1jbG91ZC5jb20vcHVibGljL2UyZnNwcm9ncy8NCg0KLS1SaWNrDQoNCg0K77u/
T24gMTEvOS8yNCwgODowOSBQTSwgImx1c3RyZS1kZXZlbCBvbiBiZWhhbGYgb2YgRWxzZSBTb21l
b25lIiA8bHVzdHJlLWRldmVsLWJvdW5jZXNAbGlzdHMubHVzdHJlLm9yZyA8bWFpbHRvOmx1c3Ry
ZS1kZXZlbC1ib3VuY2VzQGxpc3RzLmx1c3RyZS5vcmc+IG9uIGJlaGFsZiBvZiBlbHNlQHNvbWVv
bmV4Lm5ldCA8bWFpbHRvOmVsc2VAc29tZW9uZXgubmV0Pj4gd3JvdGU6DQoNCg0KSGVsbG8gYWdh
aW4hIEkgcG9zdGVkIGhlcmUgZWFybGllciBhYm91dCBteSBhdHRlbXB0cyBhdCBidWlsZGluZyBM
dXN0cmUgDQp3aXRoIE5peC4gVGhlcmUgd2FzIGFub3RoZXIgaXNzdWUgSSB3YXMgc3RydWdnbGlu
ZyB3aXRoLCByZWxhdGVkIHRvIA0KZTJmc3Byb2dzLCB0aGF0IEkgdGhvdWdodCBJIHNob3VsZCBh
c2sgaGVyZSBpZiBJIHdhcyBzdXBwb3NlZCB0byBwYXRjaCANCml0IHRvbz8NCg0KDQoNCg0KTXkg
bWtmcy5sdXN0cmUgKGxkaXNrZnMpIGlzIGZhaWxpbmcgd2l0aCBta2UyZnMgY29tcGxhaW5pbmcg
YWJvdXQgYW4gDQoiaW5jb21wYXRpYmxlIG9wdGlvbiBzZXQiLiBTcGVjaWZpY2FsbHkgaXQncyBj
b21wbGFpbmluZyBhYm91dCB0aGUgDQpvcHRpb24gYGRpcmRhdGFgLiBMb29raW5nIGF0IGUyZnNw
cm9ncycgc291cmNlcywgDQpgRVhUNF9GRUFUVVJFX0lOQ09NUEFUX0RJUkRBVEFgIGlzbid0IGxp
c3RlZCBpbiBgb2tfZmVhdHVyZXNgIGluIA0KYG1pc2MvbWtlMmZzLmNgLiBFdmVuIGlmIEkgYWRk
IGl0IHRoZXJlLCBta2UyZnMgZmFpbHMgbGF0ZXIgYXQgDQpgZXh0MmZzX2luaXRpYWxpemVgLiBJ
IHdhcyBzdXJwcmlzZWQgbm90IHRvIGZpbmQgYW55IGVycm9yIHJlcG9ydHMgaW4gDQpqaXJhIGNv
bmNlcm5pbmcgZGlyZGF0YSBzcGVjaWZpY2FsbHkgKHRoZXJlIHdlcmUgc2ltaWxhciBlcnJvcnMg
cmVwb3J0ZWQgDQpmb3IgZS5nLiBsYXJnZV9kaXIpLCBzdXJlbHkgSSBtdXN0IGJlIGRvaW5nIHNv
bWV0aGluZyB3cm9uZy4NCg0KDQoNCg0KRG8gSSBoYXZlIHRvIHBhdGNoIGUyZnNwcm9ncz8NCg0K
DQoNCg0KRG8gdGVsbCBtZSBpZiBJJ20gYmVpbmcgdG9vIG5vaXN5IG9yIGlmIHRoZXJlJ3MgYSBi
ZXR0ZXIgY2hhbm5lbCBmb3IgDQp0aGlzIHNvcnQgb2YgcXVlc3Rpb25zLiBJIGFjdHVhbGx5IGhh
dmUgYSBmZXcgbW9yZSwgc2hvdWxkIEkgYXNrIGVhY2ggaW4gDQphIHNlcGFyYXRlIHRocmVhZCBv
ciBzaG91bGQgSSBhZ2dyZWdhdGUgYWxsIHVuZGVyIG9uZSBTVUJKRUNUPw0KDQoNCg0KDQpUaGFu
a3MNCg0KDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXw0K
bHVzdHJlLWRldmVsIG1haWxpbmcgbGlzdA0KbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcg
PG1haWx0bzpsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZz4NCmh0dHBzOi8vdXJsZGVmZW5z
ZS51cy92Mi91cmw/dT1odHRwLTNBX19saXN0cy5sdXN0cmUub3JnX2xpc3RpbmZvLmNnaV9sdXN0
cmUtMkRkZXZlbC0yRGx1c3RyZS5vcmcmZD1Ed0lDQWcmYz12NElJd1J1WkFtd3VwSWpvd21NV1Vt
TGFzeFBFZ1lzZ05JLU83QzRWaVljJnI9U3BFd0E0UG55cTduSDdhTUdxOEtwQSZtPUVLYlplZ0tW
REp3cGg0aEtWVzdUYU1HbU9iczVkeHdvclhSZldiWFRkcWRVSjFXTDJhZlgyVTZ3NUU5emFuS0Ym
cz1WdWlJaS1naURORmNCSE1wU0hKcnhVVkpoWHhRbjVtdEp4UzIzYTFlVXh3JmU9IDxodHRwczov
L3VybGRlZmVuc2UudXMvdjIvdXJsP3U9aHR0cC0zQV9fbGlzdHMubHVzdHJlLm9yZ19saXN0aW5m
by5jZ2lfbHVzdHJlLTJEZGV2ZWwtMkRsdXN0cmUub3JnJmFtcDtkPUR3SUNBZyZhbXA7Yz12NElJ
d1J1WkFtd3VwSWpvd21NV1VtTGFzeFBFZ1lzZ05JLU83QzRWaVljJmFtcDtyPVNwRXdBNFBueXE3
bkg3YU1HcThLcEEmYW1wO209RUtiWmVnS1ZESndwaDRoS1ZXN1RhTUdtT2JzNWR4d29yWFJmV2JY
VGRxZFVKMVdMMmFmWDJVNnc1RTl6YW5LRiZhbXA7cz1WdWlJaS1naURORmNCSE1wU0hKcnhVVkpo
WHhRbjVtdEp4UzIzYTFlVXh3JmFtcDtlPT4gDQoNCg0KDQpfX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3Ry
ZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZv
LmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
