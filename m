Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 37230EEC2A2
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Feb 2026 22:19:11 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4fKZwn3kszz23Mk;
	Mon, 23 Feb 2026 14:17:45 -0800 (PST)
Received: from pdx-out-006.esa.us-west-2.outbound.mail-perimeter.amazon.com
 (pdx-out-006.esa.us-west-2.outbound.mail-perimeter.amazon.com [52.26.1.71])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4fKZr15hv0z23N6
 for <lustre-devel@lists.lustre.org>; Mon, 23 Feb 2026 14:13:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazoncorp2;
 t=1771884817; x=1803420817;
 h=from:to:cc:subject:date:message-id:content-id:
 content-transfer-encoding:mime-version;
 bh=uiWRBDRpPzy9hMzb2zq/cS+bELz1z0YsamQ4ESogjEw=;
 b=nHkLWO//+7YJSE+T1A4MJilHjxwoETI+dxrp5IsnYX8Ja+m/sIm1sh2a
 CblM46PFZ6Tpc+O+GdWqGgN5zt7M8CKt7zQQYWPkU877trnkL5lv1n1z1
 9EDlVZFPUav8RxsBhadxYPuW1bdAlPS8IbXhXguYSQrJ2zDcVlNLnKH16
 Zd6J9fBTlzpbKzhIum7SJcPVzQyQbH5vBsSvOV0gQm4Jo80R4+99S/QXa
 rY61UqDIqbf3nrK0Z5RiNd4PUIxlVYyy3norS/ikFUVutZi886YUgYRbZ
 SUvhjRNos6fTU/su5U2YDRHSKgMRqsZ1W2HdkqpZC2v+m9PBhtE9rvFSp A==;
X-CSE-ConnectionGUID: 2PRibHy2TdC6dND2ehZ4Zg==
X-CSE-MsgGUID: 6qP+xWMNS4CQwd3q6LwBoA==
X-IronPort-AV: E=Sophos;i="6.21,307,1763424000"; d="scan'208";a="13633613"
Received: from ip-10-5-0-115.us-west-2.compute.internal (HELO
 smtpout.naws.us-west-2.prod.farcaster.email.amazon.dev) ([10.5.0.115])
 by internal-pdx-out-006.esa.us-west-2.outbound.mail-perimeter.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 23 Feb 2026 22:12:51 +0000
Received: from EX19MTAUWB002.ant.amazon.com [205.251.233.48:1549]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.26.105:2525]
 with esmtp (Farcaster)
 id 07bad998-1282-4fef-84df-8b2a7f61feae; Mon, 23 Feb 2026 22:12:51 +0000 (UTC)
X-Farcaster-Flow-ID: 07bad998-1282-4fef-84df-8b2a7f61feae
Received: from EX19EXOUWB002.ant.amazon.com (10.250.64.247) by
 EX19MTAUWB002.ant.amazon.com (10.250.64.231) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.37;
 Mon, 23 Feb 2026 22:12:49 +0000
Received: from PH0PR07CU006.outbound.protection.outlook.com (10.250.64.238) by
 EX19EXOUWB002.ant.amazon.com (10.250.64.247) with Microsoft SMTP
 Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.35
 via Frontend Transport; Mon, 23 Feb 2026 22:12:49 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=qcb45AvagwMIPJLo7rb8InFXwWtPvuJ9b02WKE7AvzyIht4bq8kOvQl51vYcS8I9Xct3qLr4jOhb+5hvau1g3bgG7JkT64AcobcoJZR9asHbgi/qG/Pz45UzAs3ac17JSCrN+bysW6+XPeHYV4ieJYRR8f4Aewr5NC+u+0pImN3AiJLIeU4eO12ZAz/PSozZh/aB3J5DBCvviZxZp3C3FXGlmz7mdhbZdWTdOMgol6qToaA9cB5qiKytrAvswGRIkx8jqjJdCqhp+s6SMagnAdT05ywzCG2vxH8DITtdgnqEgRh1m58Pld9rIOn5oTTCzvTK4LWr+2YR+a3BVd8ZwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=uiWRBDRpPzy9hMzb2zq/cS+bELz1z0YsamQ4ESogjEw=;
 b=OiHgDd8JIZwaQlSLn273LTLV0VMqLNGOke1eK7zppievnnNTD8ZebYEoR3Iih4Z9juvYyKZwnMBxPVfDvT4KToA5k+tDEtYxPdlNtUO8kBttWle+3eI5JyN1UIWqAg52eR3qy+AE/qYDSeIf8B2nrD0CxYjFDWAp/sTaS2drRV2rcYw+gfjhRfm3ll2hTn68LGmM5pXIqZYpKMybuq2yRiIotP+b13fp0a9+SIINlKPWLO+Pi9MgrmZH5X/HdkpLUIrZq9YOJydgQ+5KrOeI9EzyTFOpmsFioekfOwXS8S4u3dK/B+5+3SFBLUrF5BNNwdpRxMP+m2y+zKnpW5SRdQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=amazon.com; dmarc=pass action=none header.from=amazon.com;
 dkim=pass header.d=amazon.com; arc=none
Received: from MW3PR18MB3673.namprd18.prod.outlook.com (2603:10b6:303:57::17)
 by BY3PR18MB4529.namprd18.prod.outlook.com (2603:10b6:a03:3b4::22)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9654.10; Mon, 23 Feb
 2026 22:12:47 +0000
Received: from MW3PR18MB3673.namprd18.prod.outlook.com
 ([fe80::86db:c59c:3fed:2e81]) by MW3PR18MB3673.namprd18.prod.outlook.com
 ([fe80::86db:c59c:3fed:2e81%5]) with mapi id 15.20.9632.017; Mon, 23 Feb 2026
 22:12:47 +0000
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [RFC] Lustre Upstreaming Project Update
Thread-Index: AQHcpRGK3EeF+w0AHEqVbwQXb0TFbw==
Date: Mon, 23 Feb 2026 22:12:47 +0000
Message-ID: <B588ECCE-7CBF-4111-841F-0510A8F5886B@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SetDate=2026-02-23T22:05:42Z;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ContentBits=0;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Tag=50, 3, 0,
 1; MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Name=Confidential;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ActionId=15dd08bf-be04-43f7-859d-0e3adfab39d5;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SiteId=5280104a-472d-4538-9ccf-1e1d0efe8b1b;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Method=Standard; 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=amazon.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW3PR18MB3673:EE_|BY3PR18MB4529:EE_
x-ms-office365-filtering-correlation-id: 8734780a-052d-4611-250f-08de7328ad0e
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|366016|376014|1800799024|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?S252dUdJOVZTRXMwZHRWeU9iT2syN2VoNDg1YnR6Z28zWElFYVZwb3B2aTB3?=
 =?utf-8?B?eUhyNW1qUnpKYUt3bEcxL3AwL2pBUk5RWU51amNPSjM0RkRkcjFCV0VhVnQr?=
 =?utf-8?B?dkNGYjdCd3p3ZTNtSlR2TFZ6SGU2L1o5WlhEZ1BzVU5VMTJzYmtiU0ZHbmtl?=
 =?utf-8?B?TG10RHlYU2tDVlFxSUdjTjRzQkVDVGRKaGZ0YVR5eFNPNkpBTjZmSkY2M3ly?=
 =?utf-8?B?aEg5WjlNODNkbzBJaWdQdXB2VTVoM0pIYkhBd3NBd0hEaVE1cTdwMzRGU1Yz?=
 =?utf-8?B?M08yZzh2SlhkVUphNHhhSnB5Y3VZZlBWdHhWaVA4RW4xVHRpZTVkN0FYOU5h?=
 =?utf-8?B?cVRlMFZ0NmVUQ1pIUVBXbnI0cXA3dmw2NG5IWndabUh0UGpCUDdwRWcxako2?=
 =?utf-8?B?eFdyRmZWckFOVGRXVXNyeEJSd0p1WVlPT2tQaW9kaHRESzhQNEt0ZDZBdEhK?=
 =?utf-8?B?b2ZaUmdPUkp1bzlEc3pGeDZNbE53MEJUQ0hGK0FnbkJmMCtvTFBTT2dvYmZn?=
 =?utf-8?B?TmxMaGdxY3VJcnhRc3h4eXNGMHpKWG9oYWErWWJOSDh3SEFPa2dTQi9JbGZI?=
 =?utf-8?B?dkhCMm4xVzhtV1U2djBMd0tGakxPdG5yOXJRak1BbFRObFE0RFVjUGlxSUpJ?=
 =?utf-8?B?V0g2SFNKYTZJRFNYZWFCZGlwaFk2eFNmckZ4Yk1oK2U2NDArcXhrNUpDMDhl?=
 =?utf-8?B?ajY4UTJFNGZncDlSdTV4Yk1zb0NMYkNnSWpPait4enZqc1pSQmNyYlRvR2Rx?=
 =?utf-8?B?ODI2Znk5M0M0b0N1SUVYV1lmVWFPdlNhdGY2WUlBWEpEMnp1YnVkeVdRcVR2?=
 =?utf-8?B?R2FURUxidGtpdXEyUDYxQnRFYmE5MUQySEZtZFkwc1JnZkdMdDk5eEc5QkxF?=
 =?utf-8?B?SklJVjBid3UzaVdXRnlEWGV1WUR6RExoYUpJcGdKVzg1UEp5WUpHOVVxVi92?=
 =?utf-8?B?Y1pnMFQ1V2Y3WjRuWmxaMWFzTVNrYXJLQUNjazZWckFRTXcrMjhRdE1hYWI0?=
 =?utf-8?B?RWUrUjZMb1V4UHhYYk1OcSs0Tmxmb1dldzMxVFFBVC9hbW9pQWVvMG5RM2pZ?=
 =?utf-8?B?QXRuM3BPUWNtSksydmdsVG1QVGYzZHlHdFY1aURDYjRTOEhrZXhHazBzUjhm?=
 =?utf-8?B?eUdxdzJuM2FuTlM1d1E3eHZ1SnpaeGtBemlKUDJCcEFGaW5nOW9UVVhJc05Q?=
 =?utf-8?B?MS95U1RwVDJvdnlwbmEyN3dYRy9rbldHNkRIdG5xaDhUNjE0TndxOGlRbFFC?=
 =?utf-8?B?a3VpcUpuaDcxdUs1SjVldE42RTd6SzBwTEVUeUhUMURQaEcya0hueTFhT3h3?=
 =?utf-8?B?U0ZMTmMwQUcwck9GSE5IakVpY2xsaHdKd3dXcHBIZlo5MW9WbGdRVjNWaDZx?=
 =?utf-8?B?T0R3YXlIdUhwMjFOa3RiU1FSazk0YTdRMnpvSHREN0xkRVlqRTFlbk9NMW42?=
 =?utf-8?B?SURqdzN6SXZLL2JmUVA1OFVrb0pqYysrRU1YdmwreHhvVjdZY0hVejZPRHMv?=
 =?utf-8?B?UTZNZnAxTitPbXBNWVozWWRvWEZybHVkS1dsdjd5YU0rQm9TVGhvNk1iNjRl?=
 =?utf-8?B?cTVDa3lpaklBbHU0cnhzU3hKS3MwQ3h2MG04b2szbHdKQ2tGMm9WSFltMmlj?=
 =?utf-8?B?S3psWlNYUTVLNVFVR0MzRmZsU0YxV1RwMDlPN3Y1RStrbW9NVHJFcGhVQTJO?=
 =?utf-8?B?bkE3TCtzMkc3L01mZ1lWMU9FMkl2eTkvODlEN1JLWXVuQU00amxpaS9YNUFw?=
 =?utf-8?B?VUszV3QvZVhhZFdrdDhKQW1lZ2dZK3Ftb0ZpZ1cwOGFrZmhaQ2tOQ0ZJWVVD?=
 =?utf-8?B?a0JrbGY3M0MrMWxFVGZMM0RYc3I5ekg3K2lrRnI5cnFVWFVYaVBFdERqTEFE?=
 =?utf-8?B?dWhOODdnRXFVQnY1UlFEdzlxdWxCYXR1R1NVRHFTTUFTR3kxK2dsaDBIb04z?=
 =?utf-8?B?MVRmeFBieWhUeXgvZVBJaHFEOUNGZTZlM2hXeXB6ejYyMHZFZXZrSGcyVU5C?=
 =?utf-8?B?ME9ZU3BFSkpKY1g0N3NEWklQNWZKeHdQM0lGMWpDdXRFL1BiNnR1RUlLaVV6?=
 =?utf-8?B?dTdiTEw3WFp3dU1iS1BMRDJvNVNDY1R6eFl2Mjc1OW1ScWEwd1FTYk5mZloy?=
 =?utf-8?Q?dUvg=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW3PR18MB3673.namprd18.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(376014)(1800799024)(38070700021); DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?Sjd1clBxTndTSDhjc3R4VDhteS9rRUM0OXlPcDFyaFRmdVZzdllOdFJWQjg1?=
 =?utf-8?B?T09WbWhsWnd5VzhmM2pzRUFLZG9wQ3IvcU9WdXJqZitoNVRpYk5qcnA4cGw4?=
 =?utf-8?B?bnRlckhEbHUyTVVkcFl6bWpKU2lOeWN1U0QrRDdjZDlaWUJOeWtXRWxsb2JE?=
 =?utf-8?B?dk80SkRyYzVtVklXa05BZ1pTY1A3Uzd1L1dxZ0JtMkFIZGFqSGRLL1NvOHd2?=
 =?utf-8?B?VVZRVkxmdjlFK055RXQrMWFQY1NOMm15cFZ5ZHFWQ2w3aDdEa3haTkVSQTV1?=
 =?utf-8?B?b0pZYWNJQ2ppN0VGYXNaN21BU0NPdElzWmkwaXZJeFN1MHoxWFFkaWJVNEJF?=
 =?utf-8?B?QW5wSGhmR2xvVmhQWDFvUTkvYkZXMjA5dWxGb1cwclIyWVp3YTYwZC92YmFu?=
 =?utf-8?B?eUxNOElweis4VVR3U3VvUU9CV2RQMjc1QjlVYk4wVHgxK0pLRUkrTFdpWXY4?=
 =?utf-8?B?MnB5RkliZTQyTXdQWGZIVDVFSVhmeGZ2UlFRRjFJbjN2RmMrMGlJMFRIMXlS?=
 =?utf-8?B?MTU4SHFtTVRwczRmUDhveGZBc2VaY09BU1BFUWZMQ0NsOVJpNGxJaThlaGNn?=
 =?utf-8?B?NE85S05GTkpnN3k2MVdPY0lyc2lOeW8wN3NZZjRaa3NjcmFnaXpxVlRFMVhS?=
 =?utf-8?B?NjlMcG81a0ljNm9OTTQ1Z0s2dVdXY3gvWFJmUU03Q1d0YVE2VmxSbTN2bTVR?=
 =?utf-8?B?K2dXNjU5dGtIc1ZtTFNiYnY1WjVuRFA5d0g1cTZZVEk2eGY3eWhVZ0NIZitS?=
 =?utf-8?B?OEFBSGEva0ZocmlxLzhIalM2azZWMXZ6cjRrKzVjUmpjVExKUlNaTUl0S2Vr?=
 =?utf-8?B?eWhVY3p3OW5jR05jTGRucngzcC9FRVJlamlLRkJibHJKeGR4d0xsL2t3Witv?=
 =?utf-8?B?aVpQVThzcm9qOW5QSGU5Q0NkamtYRXNiVDZ5amhGd3hMdUZ5VlVYS3NaQmhy?=
 =?utf-8?B?RWh1WU9HSGJVUmFFU3lBcDc5L1pTOXNTdnhkM0RoYjdkWmNSQ29CVUExT1l2?=
 =?utf-8?B?SmtRSVFwcWVBRFlMVXJ6eGxldjRnbTF5STdrb2RlQWwvaXpPM0ZLUDllR1VM?=
 =?utf-8?B?cHdyRUVieEEzWFJKL1dDbGJrVXIvNEZNUjRpU2VGbmVGYndJaklSRVNJUWhp?=
 =?utf-8?B?WW1SM1B0cW9wSXZ1dXgrdDRxc2RRZG9BazJBOHpqaHpJbS9yellSQ0tpTVh3?=
 =?utf-8?B?R0tFV0FIcEN2UEpBODVUL1k4bHAxTVNzUDNhQTdVT1NhN2tobTNPeWc3R2JL?=
 =?utf-8?B?eHdic3dWVWJYNDRwMGI5Z2lRYTgrSHMxU0hMeDRtMnpjVnl6Nzk1bjQwQUs1?=
 =?utf-8?B?WWlVdUY5b0JzejBRc0hNcldXdlNlR0lCKzgxbEtmK1RlY1VaY2ZYTktSUERZ?=
 =?utf-8?B?L2pNYVdYN2ozQUFWNjJKUlZ6TXpHU05iZGhucFlROWpCNUd5TzhmQWNhalND?=
 =?utf-8?B?ZU9ONnFUSzFQZVBDa29wTm1wVHZWb3hNczdSN2tuYnRqNGYvME5DWExQbEN4?=
 =?utf-8?B?TUxIVGU3bExQUkNsU1pUWHllNjhKZzBCWnJKcTJ3NldpTzY2R3IxT3JxeHd1?=
 =?utf-8?B?bHZUWWRPNnJ6ZXhON0hkSFdCai9uNklSNVhDS0NOWXlhSHQ5aVNCMWNkNzdh?=
 =?utf-8?B?bDEvY2RDb0FmdS9tUFh3R2RtbHV5MnZTR25EU3dwakdUSDVRdUdyZEUvUWM4?=
 =?utf-8?B?bXZWTUt4cm9kODd4OTFNZEs0Y2NZbTlTRG5zZ0tjM0tBZDNjQURCUjN3cjI1?=
 =?utf-8?B?RUl1OXJZY3dRMTdpN0lWQnBLZEEvUkZOdTVOYk9MNGJHSHJZMlRvS1dKR3A4?=
 =?utf-8?B?T3UxRzgzUHdwL01KbXVCMnVEU0hiZVJUSDNqb2pOcnZreklES2IwemNXYUNM?=
 =?utf-8?B?U0FlNWNtZzE3OGlvUEEvT2pMdFFqUjZQdWc3NlR3d0NxSHQxQWhOTVNQZG9R?=
 =?utf-8?B?Nml3Qm8wY1lJOE1JZkVtV2RWaUF5OW1WWFZCVTlTbFhNQkVoVGJGSVQ5Rzhi?=
 =?utf-8?B?clk1S1hLUXdBdFkvZlNRVG8yOExibWpZS1ZEVkVpTklzb3k4c2RWU1N4QzBv?=
 =?utf-8?B?MUFlT2FlZGNJRVBNTVhDK08yMGJxZzRDeE83NUZRcHhVa0tTSmxsSElHSmpw?=
 =?utf-8?B?QVFOTFUxN01ucXhWOTBMclhOWEJQMCs4emNjU3FIUFhFMlpUOUprQUpnc0J5?=
 =?utf-8?B?TDh2Y1NxMGpja05OMHN6ZFNNanhoaFJDYy9rWldNamp2YTZWaWoxZUJhZlhF?=
 =?utf-8?B?L1pBMEVweWtpbEh3U01MMzVMMWJrT3FWMC9LcEk2NytuSVBaSHdxMWNZay8z?=
 =?utf-8?B?U3BQcGlUamhsRi9HeDRLRitaLzEyWkk2anIyV3lKeTgrVXVxTjBUUT09?=
Content-ID: <612FDAEB218C7049916ECE709F862123@namprd18.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW3PR18MB3673.namprd18.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8734780a-052d-4611-250f-08de7328ad0e
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Feb 2026 22:12:47.1863 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5280104a-472d-4538-9ccf-1e1d0efe8b1b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: +nRKbAzYhrLj0IoLC3mYmS2rwWfbVUWUcbpFx5v+r8KfQioXDEivGzbUV6A2nyS9735VgQPBhwB08s2yucxGMg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BY3PR18MB4529
X-OriginatorOrg: amazon.com
Subject: [lustre-devel] [RFC] Lustre Upstreaming Project Update
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
From: "Day, Timothy via lustre-devel" <lustre-devel@lists.lustre.org>
Reply-To: "Day, Timothy" <timday@amazon.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Last year, we attended LSF to talk about upstreaming the Lustre filesystem
[1]. I wanted to share an update (to fsdevel and lustre-devel) about the
work we've achieved and our plans in the coming year.

We outlined a plan [2] for converting our out-of-tree repository into a
clean patch series on the mainline kernel. This process would involve
splitting our existing code base into a set of clean, idiomatic kernel
modules and a lustre_compat/ backward compatibility layer to support
existing users of Lustre on LTS kernels. So far, the initial split has
been mostly completed and we are working on simplifying the Lustre build
system and starting to clean up inline non-CONFIG #ifdefs. I originally
estimated that we would be able to post patches on the mailing list by
November 2026. But I think 2027Q1 is more likely, given the current amount
of outstanding work.

A summary of the major ongoing projects can be seen on our wiki page [2].
The folio transition is ongoing and predicted to land in the coming months,
with some of the initial patches landing sooner. We continue to move away
from Lustre's custom (or out-of-tree) interfaces - such as converting to
rhashtable or adopting the p2pdma framework. Most of the code base has
been converted (or is in the process of being converted) to more standard
kernel style - with recent patches focusing on converting from Doxygen to
kernel-doc for code comments. There are several smaller projects and
tasks that are ongoing.

Although we have primarily focused on the Lustre client - the Lustre client
and server are closely linked and we intend to upstream them both (either
in quick succession or together). Our initial submission of the server code
will only include the in-memory storage backend. Although work continues on
preparing to upstream changes to ext4 to work as a backend, we don't expect
that work will be included in the initial submission of the server code.
This will greatly simplify upstreaming efforts while still enabling developers
to easily test their Lustre code changes.

Regarding testing, I've set up a modest test bot to validate different
build configurations on the latest mainline kernels [3]. While Lustre
already has extensive per-patch testing [4][5], this bot is focused solely
on the needs and requirements of the upstreaming project. Linux supports a
large variety of platforms and configurations that Lustre customers typically
do not use. But we want to validate as many of these configurations as possible
(at least at a basic level) to minimize friction in the future. As we get
closer to upstreaming, we may investigate KernelCI [6] to surface some of these
issues (in addition to our other testing).

Overall, I think we made solid progress. While there is some work that I
wish we could have finished by now, I'm optimistic that we will achieve the
bulk of our goals by this time next year. There will be more discussion
about the state of the upstreaming project at the upcoming Lustre User
Group [7]. This will also give us a chance to discuss issues pertinent to
upstreaming in-person. We will not be attending LSF this year - although
we may attend in the future (as needed) once we have officially submitted
patches for review. Until then, I'm looking forward to another productive
year.

Tim Day

[1] "Getting Lustre Upstream" - https://lwn.net/Articles/1025268/
[2] Wiki - https://wiki.lustre.org/Lustre_Upstreaming_to_Linux_Kernel
[3] Upstream Testing Bot - https://tim-day-387.github.io/upstream-patch-review/#
[4] Jenkins - https://build.whamcloud.com/
[5] Maloo Testing - https://testing.whamcloud.com/
[6] KernelCI - https://kernelci.org/
[7] LUG2026 - https://www.opensfs.org/lug-2026/


_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
