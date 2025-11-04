Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 85AC2CCFA04
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 21:58:55 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1MF56xj3z23dM;
	Tue, 04 Nov 2025 13:35:21 -0800 (PST)
Received: from iad-out-004.esa.us-east-1.outbound.mail-perimeter.amazon.com
 (iad-out-004.esa.us-east-1.outbound.mail-perimeter.amazon.com
 [18.207.52.234])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1M8B3rm7z23M3
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 13:31:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazoncorp2;
 t=1762291866; x=1793827866;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=BeRYZuYaszYEHj/FtrQ9252OSJEgfs64VBcPTBZn0Dk=;
 b=gRytI7qlCE7FFbyDC21peB5wTYjYgT1WrIeacjtm178OYVw9AQba4NQf
 9qf+kHhHym798reFoP/ScZEX0/S6jR9kGaSTis3V9VGOwMk4k4i1Q93K/
 2m8DHWSUENEMgMIu3Dgvo8sjyR9jW0uArECLBdvKkGBUouJmC/Lilc9Gl
 huUfVjVGXBFVzb/NTi6wQf0DAagB3WNMvFQ6PPfUgoDP2au6BnEsOakps
 R3j2peVKQ58LnAFM7Q8U2rDBJJK7VYngmAPMTocYncTaYh9XzsMNSSVYA
 tRzPo4yRr945r6RK8KZE1hrW5RfGON6OdcOEwI9X71+itfQfh1hMb0tqS A==;
X-CSE-ConnectionGUID: nMuiNnnJTuCRU+XHXFrQwQ==
X-CSE-MsgGUID: K6EWpdlYQLSf/plQ/0+nuA==
X-IronPort-AV: E=Sophos;i="6.19,232,1754956800"; 
   d="scan'208";a="5739851"
Thread-Topic: [lustre-devel] RFC: Spill device for Lustre OSD
Received: from ip-10-4-10-75.ec2.internal (HELO
 smtpout.naws.us-east-1.prod.farcaster.email.amazon.dev) ([10.4.10.75])
 by internal-iad-out-004.esa.us-east-1.outbound.mail-perimeter.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 Nov 2025 21:30:38 +0000
Received: from EX19MTAUEC002.ant.amazon.com [52.94.133.130:5369]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.19.136:2525]
 with esmtp (Farcaster)
 id 24f5eca1-9a0d-4cfa-9a41-785eed7a35ea; Tue, 4 Nov 2025 21:30:38 +0000 (UTC)
X-Farcaster-Flow-ID: 24f5eca1-9a0d-4cfa-9a41-785eed7a35ea
Received: from EX19EXOUEB002.ant.amazon.com (10.252.135.74) by
 EX19MTAUEC002.ant.amazon.com (10.252.135.253) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29;
 Tue, 4 Nov 2025 21:30:38 +0000
Received: from EX19EXOUEB001.ant.amazon.com (10.252.135.46) by
 EX19EXOUEB002.ant.amazon.com (10.252.135.74) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29;
 Tue, 4 Nov 2025 21:30:37 +0000
Received: from DM2PR0701CU001.outbound.protection.outlook.com (10.252.135.199)
 by EX19EXOUEB001.ant.amazon.com (10.252.135.46) with Microsoft SMTP
 Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29
 via Frontend Transport; Tue, 4 Nov 2025 21:30:37 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=pnUWRzHsKHUBJmEpU4uusO8tLoRK9hKG0q0btlKuYUPExpBkKNohaDIQ2BAgHW2kk7T+5eRhkE5cvOMvW+GowvkVEsRVIqdDVtakE34bEzfxOjr4AhSqdnSO/FJsNrFlYICKRujm7GXtID0Igx2veRjaP8ofFxmEVqsTZVNKbiwTAccIehJkKkezxD0bLQj1ZfswmwfOFKRvzSy11fZazBTLWf59ux3iYvF0XS7xRuGaRfPvz1y2o0teipJMKqEYlQc0qF84eKmTnRzORrqgwAR4f4RNV7By3c0W5OML5qpOzMddKGSrfXtkHVWHjl4IAOiWzlEdjXWIoEo/Q1Seng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=BeRYZuYaszYEHj/FtrQ9252OSJEgfs64VBcPTBZn0Dk=;
 b=r5G5ONRXECyJgkwFUpSNL/WkTcoxagugjYvTM8vS7ANK1QaKTlQ02q/NTkr6eRhtMh/dH8wEiAmUfv6SjY8U8uuiVPb7IFc+gnfMI5htA0DT67tD37FtVAXSAL4/1NMoyr1dA3C+xf+p5TfL/J10D9lV3FK9CrPpVwFuXJwSorfgjjcWbX+Fwiqo+dU8srg4NUQG2neZpQZgoHSGj2hFTszBt2fNArDYPLdn1lIIbotUS7zlD08GInFODD1DEdrl91+K8scSMGNbVgYFD6zXKnrJXdOjfZ/m/fRrqXT+LT6kuXZBLwzsgIq21UgLoSS0pLDW6mhFiTUTTU8Peh57Og==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=amazon.com; dmarc=pass action=none header.from=amazon.com;
 dkim=pass header.d=amazon.com; arc=none
Received: from DM6PR18MB3667.namprd18.prod.outlook.com (2603:10b6:5:2ae::22)
 by MN2PR18MB3656.namprd18.prod.outlook.com (2603:10b6:208:26a::13) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9298.7; Tue, 4 Nov
 2025 21:30:36 +0000
Received: from DM6PR18MB3667.namprd18.prod.outlook.com
 ([fe80::2aeb:6b41:4331:4be1]) by DM6PR18MB3667.namprd18.prod.outlook.com
 ([fe80::2aeb:6b41:4331:4be1%4]) with mapi id 15.20.9275.015; Tue, 4 Nov 2025
 21:30:35 +0000
To: Jinshan Xiong <jinshanx@google.com>, Patrick Farrell <pfarrell@ddn.com>
CC: Oleg Drokin via lustre-devel <lustre-devel@lists.lustre.org>
Thread-Index: AQHcTRfVShgBRRhEzUqH3Nrq5pk4FbThou2AgAADJwCAAAUVgIAAF8mAgAANjYCAAPkLgP//7PYA
Date: Tue, 4 Nov 2025 21:30:34 +0000
Message-ID: <85EBE389-4753-454B-9735-B57039CB003A@amazon.com>
References: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
 <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
 <c6c016567a02f857303eedb9a4af6b5831c2c818.camel@whamcloud.com>
 <CAEp8vpiZ8iKRbjy8GYKdXFjsycW=a48baOXxUnSP7uE+Xf5cYw@mail.gmail.com>
 <e31f82d56f034cb325ae29a08280122711078a97.camel@whamcloud.com>
 <DM6PR19MB263631D5057975AB09DB7F60C9C4A@DM6PR19MB2636.namprd19.prod.outlook.com>
 <CAEp8vpi_VWA9EXJjED73MmJCMwp-zzi_h+7taB8uohExJY0tdQ@mail.gmail.com>
In-Reply-To: <CAEp8vpi_VWA9EXJjED73MmJCMwp-zzi_h+7taB8uohExJY0tdQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SetDate=2025-11-04T21:23:56Z;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ContentBits=0;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Tag=50, 3, 0,
 1; MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Name=Confidential;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ActionId=31974ca3-b4c2-4ee2-8b9d-060a11105962;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SiteId=5280104a-472d-4538-9ccf-1e1d0efe8b1b;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Method=Standard; 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=amazon.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM6PR18MB3667:EE_|MN2PR18MB3656:EE_
x-ms-office365-filtering-correlation-id: 7f9da919-4b27-4ceb-ffdb-08de1be963de
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|1800799024|366016|376014|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?LzJoRnpEV1Bwbzk2OHRFSzF1Mmc3QkxZM2p3Y1RUOVRKK09aV2NrT2xLRk03?=
 =?utf-8?B?WUp6aSt5cU1tZkh3WWp3a1AvSnZGSjhiaXk1NUw3aW5HRzlCTk9ScDdLZkhQ?=
 =?utf-8?B?ZWJOK2xneG1oemZjcmpGWmFSbFRLY3FIK2xuRmNxVWFCR3hqenowTHQyWmJ6?=
 =?utf-8?B?VWxDWUhyTkpaajN5ck8rMEdaTkRyV3FVMnpoS0Z2Q094SGhiT2xELzRkRjlx?=
 =?utf-8?B?RUxJYXF5aVRtOG5abWJ2eVpUalR3UjI4SVVnMzNNZGhSUE5qdERLbTZTa25H?=
 =?utf-8?B?TFc2SE9mTWNLa0hqYUVLSG5LbWVzc2ZRMVh0OXEvUnZObExicmFrZnlvcUlI?=
 =?utf-8?B?ckg4bUc2UWNrQzhMbTZiVlNrQXBxWXNqaDJKZXcyZlVNSy9KY3pibUdqN3pZ?=
 =?utf-8?B?b21ic1pGRWZSVWxISEdxT1BZcGduTzR4dWdDR0ZqTlJoKzZBWG8vU3J0ZE5E?=
 =?utf-8?B?MHNQa2YvbVNBQnJZVGhxRlBocG5pdU5UeDBUMFFxZFlId05paGVaSHhaWEZN?=
 =?utf-8?B?QzM2QTRoNzVxR0VKTXF1WHlWM1QrV3B6aG9oSDNCRjhzNldITnJTbmZHalFO?=
 =?utf-8?B?Nm9jQzdWU05QSlFzNFlmTDlFZWNkQWFSNE1ib0FFc000ZkpLMGdOanRmOTAv?=
 =?utf-8?B?aTVUYnBKWkM5aDVlZ215RndXWFFDUWVsRFByVUsvUG0zMnBuanpmTGZKditt?=
 =?utf-8?B?NVJGU0xDb1cvY0ppRHc0MWwzR3g1NVlMYnBsajVLVkJUUVZSL3VRc0RIQjBk?=
 =?utf-8?B?anFxL0tHSWc2T0pIbWZlRHdPUW9vczQ1RXQ2eGxsQkRtS3JnYTc2TStKQ2U1?=
 =?utf-8?B?T0NhZHNLcmZMbHdkUVZQK05TUW9YRkdmK0ZjYjFmVk9sUDFUbHF1ZFRMQnlZ?=
 =?utf-8?B?WTNmcUhPMXFxbzlQdVU5SUVhUFdXVWZhcVNpR0RUYThGVzVjYzk1emJyYi81?=
 =?utf-8?B?Vi9icEl6MWczWCtYYzNVR2JoVUl1Q0dLRHZ1dHhQZVlhTDJEUnRhbUdtbTBp?=
 =?utf-8?B?dmhCNFgwQkExUFFPMzNHNmNURVo0SlRvR2lTZHp2Q01NdXdnLy93Snp2eTdw?=
 =?utf-8?B?ZVllR1hFSjJ1bklTbDE2dTY5c3FQb2RtWGxwVGlZUDZrS2E1K2Yza01iSHdG?=
 =?utf-8?B?L0xwMnA4WFJaY1ozb1Y5bFh1aG53U3B1UHVvME1XT3V6ZWtDMUhIbzBrb2hF?=
 =?utf-8?B?MWtoNXRhTlZsVlhTaEU5Q1ExZTIyV294WkZJOUQ2bmFEajhaYytSZkw0ckx2?=
 =?utf-8?B?eFc3aCtTNndER0g0UitVa3lUWXlBdWZOd1ptV2ZoRnQ1VzYrWWRtckptZ0Nt?=
 =?utf-8?B?bGUySm15azIwN3NqUlRrSlBBTW1VZjFzWDBpc0JKMDdlN1dLbWlCQVI1aEkr?=
 =?utf-8?B?SUhDS0JOdWpWRlR0UkwzdytHeTFjZGF4Q0NJNUNnS2xLUG9xTlpiTlBocHBK?=
 =?utf-8?B?M0IyU0xOWCtjb1N5SVA4NllHWXhGZkpYUEpMSWJMUjVpZ25yeUJxamtyZ2do?=
 =?utf-8?B?eFBadVZ1bXFKUklObkpNZmZEaXlRcTI2bFh1Y2dubzR1eGowY1Mxalh5aUpR?=
 =?utf-8?B?Z0RDMFkxV2NJOEN5eGN0TS9YcFJxUHluWGorSXNsR3VZWjBudXorWXI0YlZH?=
 =?utf-8?B?NVhINktFYWl3VlFkMnpDQWFCVkNiamR0YTV1YXpOM0lFZ0g1bjU2OC9QVUVu?=
 =?utf-8?B?WGJtWlBwSXA5ZDJ5bWEra1duMko5UnpBeTBzZy9MQlNmQUxrVTRVdmpYVEY4?=
 =?utf-8?B?M0NHaG5MMWpZWFpxaGx0Y1pvWklzZCs0aXVPZWRqWnloWXd4VmdkdFJocHBS?=
 =?utf-8?B?a2JCZHViQVJ0ZjY2eWFpb1g0OGx6WjJFZm1TRTBaTGtnR1JEbG84V3pYUVJ0?=
 =?utf-8?B?dXd5anB4Y0NwVXVrZE01ck1mVWN4NXZweGdiZUl3MUtUYndORU5BSkZ6QjJk?=
 =?utf-8?B?VlVQclc2MmJuNXBkOFRlREhuYmQySEt3QzQ0QVh6K2FQY0VtcWljRlFJL2xv?=
 =?utf-8?B?d2dzN3R2cXFoRTVQWW56d2gzazBIdmdhTHF5YnBwMFE0d3dkSStUWFlKMWpu?=
 =?utf-8?Q?+MHiD8?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM6PR18MB3667.namprd18.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(366016)(376014)(38070700021); DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?Nk84azAxTTVSZW5obWNJSkJib3Q5RDBhUXZRM05abTU0N1kxUTdacDYzajAw?=
 =?utf-8?B?eEN6STRFN0lzVmIwbGl5STFoN2ZsSGYzOTZteGdEWnNTazN3dGQrWmM1YytB?=
 =?utf-8?B?K00vL3NiTEpHbC8rekNwS25lTk5Uc3QvSzdVbTQ1ZHJXcmsvOGladi83blFQ?=
 =?utf-8?B?aTRpT09LRWR1WHlVaThib2E2ZWFzKzY5YVZ0UkxUU0U3Nm1YR2ROUWVObldh?=
 =?utf-8?B?MjBqZG5QOWhEamFwczlCcDQ4TVR5S0F2UlM1Z3RqOXowQUlWblNpemJtV3lF?=
 =?utf-8?B?NU1laDQvTGRKUjQwbEpNVlV2bUkzZVk5SkF1VlJUYnF5TlNzdnR4NVpKTk11?=
 =?utf-8?B?K00ydEJlZE1vNjdJZEticExlaTUxZHVpSzNyQWpVbWc0UGlsYnpWYkFpaks1?=
 =?utf-8?B?SHRXeXVrWW0wTVV6aEZ0RkQrWUFtR3U3dE5NcDNnZmZ4bkNVOFB0K1pPZUlj?=
 =?utf-8?B?SDNOSUxRaHNMZHMxRzVGM3RaM3RSY1RpQjFnYU1FS3V3d3R3eWpFNlpNR0Vy?=
 =?utf-8?B?aDZKS2pneXBSOVo1TzFzRjNGTGZZRlNWQmY1ZjV0ZGo3OUZhczlYeWRhaCtT?=
 =?utf-8?B?ZUorMmQ3bUdxdlFnMWo1TTQ0eDh5ZlowR2Z6MkN6YkFwaVFBWHVnTmZpMStM?=
 =?utf-8?B?L1RSb0dkVFlOVUVUem1mSzI5UFRHSHNCV0xONXVYdFFsdmxtdXR5VlN5S1Vx?=
 =?utf-8?B?QzRXVUZCS2xCVm9iQkZGdjVDdlNBcjNDQVBWbUJFZUdPV2x4Ymd2Sm5TNXNn?=
 =?utf-8?B?ZHZpUTk5dFRLWUlPR28wZDdMKzVCcnBtUnUrY3pmMWM1T3RsMGp0Q2t6YWhF?=
 =?utf-8?B?eVZVL0VQRXh0ZXNPRW1UMG5ka1FCWGxCOXpRYXZkWldWODdZM2FSanZzVUMz?=
 =?utf-8?B?OHI1SmpnekZxZ1pvam1sTHZBVDIwejg4Q2JIS0ZFcFRhZXpmY0t6eDhFZkQz?=
 =?utf-8?B?MFJSV2hhelpKOEJlUGVpemhzOUw3VGZHVElJSkw1c3IxNVZvK0NLUW1HWmdP?=
 =?utf-8?B?ZkxkZ0ZYSHR4MjA3bW53d245d0hUVHE1WkJ1bDYycUVJdUxXZWtwUysyS1BS?=
 =?utf-8?B?SFpJS1lRa0hnUmdHTHJYdG9hYjExL1psVkFmVkJ6SjJDc1Rsa1dVM1I0TCtO?=
 =?utf-8?B?akVFcElPa2NnT0FtTG1PZHF0MDNEZGExY3pBeWdsNGo1NlhaN2daU2dOcmpT?=
 =?utf-8?B?Q1Y0QXdZMjZRbFVPaU4rdHljR2VVTzRERU5vZ01vQU9RNy9KUjYxTXB1Y2pY?=
 =?utf-8?B?ZUU5NXd0VGFjanM0VHVBaGNjL3F4SEc1ZkdGaEM5d1lWM1JDSFZPTFpkOXA3?=
 =?utf-8?B?SVIwczJQZ0xkMUc1U3Z0Mld6VFhkK1l1VDc0ejFja0pYUUZsaXdLMzA3Ri9r?=
 =?utf-8?B?MGR2anhNRjRPcy96NDkrWnY1WVhGWWxWQTdTb2dKUTBIL2cvVmxybHlYbzZo?=
 =?utf-8?B?WVIvb2pSZXJpdzZ0RGhla1dZNkM0RzYxUTRUU2dWM2V2ZVNFT0RmaERZbDYz?=
 =?utf-8?B?MmIwM2hrZjR4ZG1zTDRmNk11N1ppS1dYOXp5a3BNRjFRdFdmYUtDMWI2TG1X?=
 =?utf-8?B?TENXbXJEdjU3MnlHeTVjYmtldU8wRkE5ZDRwUzBtOFhLb29DZjEvV1NxK0Ew?=
 =?utf-8?B?WE1GamRRZ2U5cmo0R3BPUGFTV2c5UGpTZG4rWjRqZlFML25VV0ROTWVmdllF?=
 =?utf-8?B?LzNLaWYxc2MzT2YwZ2U0VkI0Ung4YXUvVi9xSW9qYVRIZ3MrSldCalZNbnJB?=
 =?utf-8?B?WTJFaTdUQUFucTRDTTRoUkZYaUw3cnlBR0xxQ0owOTNGT2tpZ2QzckJyZTAw?=
 =?utf-8?B?YVVPNnFNNyt6WDU4TWxTTDk2S2x1d3gvSkhXekJmNmUzUVovZ2JjVDVINmxD?=
 =?utf-8?B?a0thL1FkZVdNMUhUTXU4Nm5lMVNkYW5vZVZoS0dTU1pBQlQyMWlja2diQ3Er?=
 =?utf-8?B?SlMyRXEzbW45ejUxWWVkdVI2UmVPUkV1RTAvNTlaNUZxeTM1dXRwcDB6Ykhk?=
 =?utf-8?B?azVXZ2h4ZndhMUVwT09LWVpnZC9iTG52MlZsSnNNc1RvNzNGQVk1bnFFMXd6?=
 =?utf-8?B?bVlINTJzZzFEQzNEM0FwVlhvK0pVeHZvRXYvbHpQUHJaOXI3UzZ3R1NMcVBQ?=
 =?utf-8?Q?5uDxxmTqD+d8kOnwyhRKBUf9Q?=
Content-ID: <67851B9D8F545141BC545BC31644E49A@namprd18.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM6PR18MB3667.namprd18.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7f9da919-4b27-4ceb-ffdb-08de1be963de
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Nov 2025 21:30:34.9808 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5280104a-472d-4538-9ccf-1e1d0efe8b1b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: mgY0MAjsplRPexA66kPCASPGTy54s2Ubl8+i0CIaxnm1beUzPbZ2jRh+1MxNc3w38pqVnh5o10/JEuA/+u0wdg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR18MB3656
X-OriginatorOrg: amazon.com
Subject: Re: [lustre-devel] RFC: Spill device for Lustre OSD
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

PiA+SSBoYXZlbuKAmXQgc2VlbiBhbnkgbWVudGlvbiBvZiBmYWlsb3ZlciB5ZXQgaW4gdGhpcyBj
b252ZXJzYXRpb24gKG1heSBoYXZlIG1pc3NlZCBpdCksIGJ1dCBpZiB0aGUgZGV2aWNlIGlzIHRy
dWx5IGxvY2FsLCB0aGVuIGluIGZhaWxlZCBvdmVyIGNvbmZpZ3VyYXRpb25zIHRoZSBkYXRhIGlz
IGluYWNjZXNzaWJsZS7CoCBJZiBpdOKAmXMgKm5vdCogbG9jYWwsIHdoeSBub3QganVzdCBtYWtl
IHRoZSBkZXZpY2UgcGFydCBvZiB0aGUgT1NUIG9yIGFuIGluZGVwZW5kZW50IE9TVD8NCj4NCj4g
SXQgd29uJ3QgYmUgbG9jYWwuIEFjdHVhbGx5LCB0aGlzIGlzIGRlc2lnbmVkIGZvciB0aGUgY2xv
dWQuDQoNCkkgZG9uJ3QgdW5kZXJzdGFuZCBob3cgJ2xvY2FsJyBpcyBiZWluZyB1c2VkLiBDbG91
ZCBvciBub3QsIGFsbCBvZiB0aGUgTHVzdHJlIGNsaWVudCwNCnNlcnZlcnMsIGFuZCBiYWNrZW5k
IHN0b3JhZ2Ugc2VydmljZSB3aWxsIGJlIGNvLWxvY2F0ZWQgaW4gdGhlIHNhbWUgZGF0YSBjZW50
ZXIuIEkNCnRoaW5rIFBhdHJpY2sgaXMgYXNraW5nIHdoZXRoZXIgdGhlIHNwaWxsIGRldmljZSB3
aWxsIGJlIHBoeXNpY2FsbHkgY29ubmVjdGVkIHRvIE9TUw0Kc2VydmVyLCBvciBiZSBwcm92aWRl
ZCBvdmVyIHNvbWV0aGluZyBsaWtlIFNBTj8gRWl0aGVyIHdheSwgcHJlc2VudGluZyB0aGlzDQpk
ZXZpY2UgYXMgYW4gaW5kZXBlbmRlbnQgT1NUIGJyaW5ncyBiYWNrIHRoZSBwYWluIG9mIG1hbnVh
bGx5DQptYW5hZ2luZyBkYXRhIHBsYWNlbWVudCBmcm9tIHRoZSBjbGllbnQgLSB3aGljaCB0aGlz
IGRlc2lnbiBpcyB0cnlpbmcgdG8gYXZvaWQuDQoNCj4gV2UgYWxyZWFkeSBoYXZlIHRpZXJlZCBz
dG9yYWdlIGJhc2VkIG9uIG1pcnJvcmluZzsgaG93ZXZlciwgdGhhdCBzdGlsbCByZXF1aXJlcyBj
bGllbnRzIHRvIG1vdmUgZGF0YSBhbmQgYSBmaWxlIHN5c3RlbSBsZXZlbCBzY2FubmVyIHRvIGRl
Y2lkZSB3aGljaCBmaWxlcyBtb3ZlIHRvIHRoZSBjb2xkIHRpZXIuIEl0J3MgY3VtYmVyc29tZcKg
dG8gbWFpbnRhaW4gdGhvc2UgY2xpZW50cy4NCg0KQWdyZWUsIGl0J3Mgbm90IGlkZWFsLg0KDQoN
Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmx1c3RyZS1k
ZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcKaHR0cDovL2xp
c3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnCg==
