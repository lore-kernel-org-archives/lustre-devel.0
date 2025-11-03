Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C4EAFCCF9F8
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Nov 2025 21:59:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d0lq600gbz1y22;
	Mon, 03 Nov 2025 13:59:13 -0800 (PST)
Received: from pdx-out-009.esa.us-west-2.outbound.mail-perimeter.amazon.com
 (pdx-out-009.esa.us-west-2.outbound.mail-perimeter.amazon.com
 [35.155.198.111])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d0lq36s49z1y1g
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 13:59:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazoncorp2;
 t=1762207152; x=1793743152;
 h=from:to:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=uC8V7cOt8Xjzthyqrh++MyjQMjfvpAhQFlHEiJmMrPw=;
 b=DI3diwHH66wVLGQQK43/ny4IQrptPMDZen4cj54mYnIq+X3QQGJcG7YV
 W6r6zfy2Y/rIZOfW50ILhV8fmjtgqVLKlb5jEHdm5SANblbfD53luFFEq
 1Tu5RmJFKdxm+hUPvVGRORoNWizZ1PKMmwsC9NjTpnq212zba0Cl7fFex
 g6PxUqjtVDjCH2aCP3YqQ8atvdvdp4ir0x3L7jyshQD30JGmDshRXyQor
 DLmJNmwLEvloh92+YnWpml8tp+zdV9CS+77TzYh79a/uf5trNdTxas8oA
 ZZURm13c102Vj1+1cS0gf6dddXEzhQl88fXKa0RGwoV1YBIiAC9wpa6BT A==;
X-CSE-ConnectionGUID: /7CkcxPESBenC6WXlP7hZg==
X-CSE-MsgGUID: a8YycVpFTFuG7zPXVp6xiA==
X-IronPort-AV: E=Sophos;i="6.19,277,1754956800"; 
   d="scan'208";a="6176778"
Thread-Topic: RFC: Spill device for Lustre OSD
Received: from ip-10-5-6-203.us-west-2.compute.internal (HELO
 smtpout.naws.us-west-2.prod.farcaster.email.amazon.dev) ([10.5.6.203])
 by internal-pdx-out-009.esa.us-west-2.outbound.mail-perimeter.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Nov 2025 21:59:11 +0000
Received: from EX19MTAUWA001.ant.amazon.com [205.251.233.236:19354]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.4.171:2525]
 with esmtp (Farcaster)
 id 4cc5be2a-8507-48e8-9951-5c71f4db74db; Mon, 3 Nov 2025 21:59:11 +0000 (UTC)
X-Farcaster-Flow-ID: 4cc5be2a-8507-48e8-9951-5c71f4db74db
Received: from EX19EXOUWA001.ant.amazon.com (10.250.64.209) by
 EX19MTAUWA001.ant.amazon.com (10.250.64.204) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29;
 Mon, 3 Nov 2025 21:59:10 +0000
Received: from SJ0PR08CU001.outbound.protection.outlook.com (10.250.64.206) by
 EX19EXOUWA001.ant.amazon.com (10.250.64.209) with Microsoft SMTP
 Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29
 via Frontend Transport; Mon, 3 Nov 2025 21:59:10 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Aw4syO4KreiHxw/XiMKa54fP6PkikB6oZwsZHJM7RnFeisY0V2TDRlppOQ/6F1OZ6bYDhSRUzE6zqMB7TvlgAFzdoQ95LURJb66Y1YDDH21qZDr+SHGxRK3/20ARg5ynrQ75JVM//dY533MV5WCRgZtuEcVVdzABupQyEWDktnrkAu16b6Fhn7doubUdMOnoAsWgh20Qs7JfBziAK6Yhs39XF6147+5YPX8oDb/suqIBADUtRL/XxLOhdMn3AqpAXjeWNRMjSfS9GJvJwmexd1hZnn6XfnBGwSHYmjHcvWViVu5830HEyvgXm/jrKhEJRKBxFr7cVXljK18vOx4v4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=uC8V7cOt8Xjzthyqrh++MyjQMjfvpAhQFlHEiJmMrPw=;
 b=ZefrB08rPdX2AAnhli8SgPorf7LxlK4QokBX5NtREJ9ooyZQWdP1begxQMagLp6D/tDYg6h2gOk+nQ3gEJF2Ini1skHK+SNSMmMySgqGT8iFtyGohGwNzXYgLcPySioUi/XpZ36LhMHnf8p+5Mi9wqFkPYcALAuGRVZDzwWAPTTpk6reIyV1THFXC7lAH/W8y6h2h1MNrXLWq9noFoz1BCRd1ISzFUPpTsUuod/Jp4lV1i2kWDD68DYarsmmjTW/KZZPt64CEiOXWJfYvcG45UCDGT9ja+wqbMG+BLRnyipwLdwLCxBIYMMtoRQ8Ml6Eqm4UrAO654yB7SwB3dEoKg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=amazon.com; dmarc=pass action=none header.from=amazon.com;
 dkim=pass header.d=amazon.com; arc=none
Received: from DM6PR18MB3667.namprd18.prod.outlook.com (2603:10b6:5:2ae::22)
 by MW4PR18MB5062.namprd18.prod.outlook.com (2603:10b6:303:1b9::12) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9275.16; Mon, 3 Nov
 2025 21:59:08 +0000
Received: from DM6PR18MB3667.namprd18.prod.outlook.com
 ([fe80::2aeb:6b41:4331:4be1]) by DM6PR18MB3667.namprd18.prod.outlook.com
 ([fe80::2aeb:6b41:4331:4be1%4]) with mapi id 15.20.9275.015; Mon, 3 Nov 2025
 21:59:07 +0000
To: Jinshan Xiong <jinshan.xiong@gmail.com>, Lustre Development List
 <lustre-devel@lists.lustre.org>, Andreas Dilger <adilger@whamcloud.com>,
 "bzzz@whamcloud.com" <bzzz@whamcloud.com>
Thread-Index: AQHcTE/AGdVndrjiSE2WWCbdtaJ3z7ThLbQA
Date: Mon, 3 Nov 2025 21:59:06 +0000
Message-ID: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
References: <CABoqRjtUuma_HLj7GK=2qUEWXV4XB11eEN6yj6svPtn-q+d4fw@mail.gmail.com>
In-Reply-To: <CABoqRjtUuma_HLj7GK=2qUEWXV4XB11eEN6yj6svPtn-q+d4fw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SetDate=2025-11-03T20:58:19Z;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ContentBits=0;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Tag=50, 3, 0,
 1; MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Name=Confidential;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ActionId=41ed7049-72fb-4b69-b268-899415da53cf;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SiteId=5280104a-472d-4538-9ccf-1e1d0efe8b1b;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Method=Standard; 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=amazon.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM6PR18MB3667:EE_|MW4PR18MB5062:EE_
x-ms-office365-filtering-correlation-id: 6cdb3f02-3a87-401e-cf6c-08de1b24360d
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|366016|376014|1800799024|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?dFVtNjhkVFpMQ2xwcFNDa2NzZTlENmNJR015dXlSeXJBS2tCVDlQbW1xQWlu?=
 =?utf-8?B?QTNkU0tzWDIwdGJKbVlXV1JtSFdZdGt5V0Z2QlgyL3JoQitzYU5EdHNsM0ph?=
 =?utf-8?B?c3dlVEViNDYyU1hDNjZMNnptbDl1cm1HT3d4aVNhQlZNVElhL3djT2ZkbEdl?=
 =?utf-8?B?YTgxTVdzT2taeTA5eStQZ2tzakJwakJGMWxxMlRRcGs0Wm15QVA1TEEzNjdZ?=
 =?utf-8?B?QmhrRlg4K1J3VWxmOGd5VHlFdk5kMGNWLy94d0dNRjB5ekFGeGJjdlBhNGZs?=
 =?utf-8?B?UHlVMTdYT2IvQzN0ZFovUUxsZWI0NlMwSVhuK3Q4R0dMTUVqaGF4MVk2VStO?=
 =?utf-8?B?ZSt3TmViVjhLa3hhOWNrVjdvN295aTdsaHJIN21ZRGpRMzdGTG4vYjRzQXhY?=
 =?utf-8?B?WlEzQTVCNzV4SGNBQm8vRG4zb3VZQUE2R2RuQWsxNXA2aEVmU0NNdXI0dmFE?=
 =?utf-8?B?UitxK2ZWMWFpZUVHdm52T2dxK3pOZVVCZ2lXQnpEMDZsUVdSbkcxRWg3SDlz?=
 =?utf-8?B?bUc3MW9aYTM1U3IvTm1BS2RVelFQamhOVkJaNFVzU29CdkZ3QnFlVFBQcGI0?=
 =?utf-8?B?dmNtWEo5OEdCRzZBVWVzeC93b2MvV09QV1oxVUNVRlpMV0Fla3BiME9VOTFQ?=
 =?utf-8?B?UDBuaTBPS3V6dUlNWnFHdnBYb2ZmeUtYMXNCTlZpcG9aNUxzNjlNM2syMlBN?=
 =?utf-8?B?WC9lcXlmVjZmTzN2ckJSZnFvVURmZTh4ek5ybTN1L1pSeDk3U2lEWVhrdUpO?=
 =?utf-8?B?SEJuZC9UOG4wQWl1dDBTZGtjR21CWk1tNHR6TVlieC83N3VrWE1hTS9hNVEy?=
 =?utf-8?B?VVNiZXlzY0dnWFdKcVg2OVBvQmtudVRYdFNZVmRhbGVJRGltTEU1RmhWeUdX?=
 =?utf-8?B?dzBYUjlSVXVRQUdvL29NU2hkL05EMEd2QWlhT2oxcDRMK0VFZWpvdjg3SHpZ?=
 =?utf-8?B?K09ib2c2QVFtRk1CTGJtditPTHcvS1B6VnBSdlFnemVxTVVUcG1vWjhJZUxP?=
 =?utf-8?B?NG5mckpaOU1uQmJ5OVJMTlVsVVZFeEdNQnZ4TjRrWFp0SVVUZDh6MEdIcTly?=
 =?utf-8?B?OGhMUW5HZzNUWW5xL2d1ejJSRWVxbW5DcTlYb0pHK09IYTZPajJEL2V0WVlD?=
 =?utf-8?B?VnNPa0pPWmhRaFV2Y0ZtR1VwK1lrMVBBYk5nMktLMHE1cUJEbjZWTndIN1o5?=
 =?utf-8?B?QWVWMDN2N21VUXcxdGw1T0szNitoZGgwSzZEcXdjblBtQWRaS0ZkQi9nR1c1?=
 =?utf-8?B?OW04aThDSHZrQStCdkd6Rm9YekJhNThmV24wNjZzWVQ0Mjg0R3JtZGt4bGFw?=
 =?utf-8?B?UnRtdDNyZUZTeG5rbklGLzVhcXJDZHR1UTNlV3F0Q0VkaTVnRW0xbDdYQW9r?=
 =?utf-8?B?V3NhNXdmd3dWbmZHd1VZbXhFcDVxVlpwbDUwMTlmSFlJTTkzcFVDZkVTMkNn?=
 =?utf-8?B?ZkM2TlZ5MExPU1U4dDNWRi9BenJRb3ZGWU5hMEhlZjgwbXk5bmFaSHNwa0NP?=
 =?utf-8?B?dTRvOEw5SmtPcVd1SzhwQVc0MHEzdUlmZzlDd0lRV3UxU09lM0RTVU5JQU52?=
 =?utf-8?B?cFN6TkQ3bms2OEduLzYxeDVzRTRtWm94a0ZxZnFVSWUvZHRHRVVuQ0ZIQjMx?=
 =?utf-8?B?a1BjT3ZUVUYyQ2ZpcEw1TzNSalJNT3FCT3FGZEpnc0RnRVFYTnF5OGlkeWxN?=
 =?utf-8?B?Q3grNjhBRWtzR3Jtd2NrUnRxRzZlQXdlOXNIT3NBb0J2Ti8rY0NUdkFlR0Fl?=
 =?utf-8?B?NXFPOGtRT2xyeEUwRmN5blExNUpKejBPL2hhdVFIdU9GQ3NGb1RrMEw1dkFq?=
 =?utf-8?B?alM5amxKVnVMK1ZLZzFNakV3bko2dUM4bmRNcEM0UlNQVStSbEErWDY2MUpv?=
 =?utf-8?B?dWsrcmgyU0VxakNLeHZQdzNsaEQxNEJXSlFpRlUvblU0MHBpTG1HUGZYZEdm?=
 =?utf-8?B?NXJzVHV2ZFU3RkVZMGlYOTVLeFI2ZWh4UEhNdGpGMGVIb0hHUUVrd09maXFt?=
 =?utf-8?B?RElOSFBpKzhnd0g4QUdGMkJBVW1PaU43NUxLcitrb0hiYWdhWmtoNHZncDQr?=
 =?utf-8?Q?eTrG4J?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM6PR18MB3667.namprd18.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(376014)(1800799024)(38070700021); DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?cmJjY2JDdEFSb05vVVdmcnZvanB6T20vcmJXZXZVeUhzVWdSUS9WQ1JtYklZ?=
 =?utf-8?B?UFJNQy9aOWZMQW5NRTYvUnMwSEdqay9LRi9LWm9kTE9nTS9rZkJzWTZGSDVC?=
 =?utf-8?B?WWs3d091VFpHTUNmbm91MlZaYzgyckxHaDBCWktqb3NxRkpmRmNQcUE2Miti?=
 =?utf-8?B?YTR0dDE0b3F5U3V3ZWRqTThNY0c3dXpnTEdEcXcrMjBPbmNTMVhjampQY09M?=
 =?utf-8?B?THJWNjA1VXAwT0JaT2oxZWRIWmxJWU5aMUJpUWZRR3NyM1ZuYnBlUTB2ajZu?=
 =?utf-8?B?cEJFVll5QUVwR3pIVXZwZXAxb1RFajdqam1lQXNNeFZabjEwa3hRdlZUYUdx?=
 =?utf-8?B?a0NEaTFTNmQ3UjZQcjNCR0RnTmJUZTZOaEVJNnRJZ09iVzdJelloVjFHSnlq?=
 =?utf-8?B?VStKMHhBRW44QitUKzllNVpCUjF0V3JEa0JPOTF4b24yTXdyMGp1TkY5Q3Fy?=
 =?utf-8?B?R2I0T2k4dFBuQWlDMjNPa0Jrb08yUS9pdUF2cktjNkI2Smt0RDN3cElKMGpa?=
 =?utf-8?B?NC9mZnNSdk9xN2pxa2lCNTdINWZkZGN6bWNXOEpRVGR6TzhmVXNVMzAxelVL?=
 =?utf-8?B?elRTNFJYRGp5cXdPcUZQMFh6Rmc3RHgvbitzVjRvUFpJODdsa01IcWZSbDQ1?=
 =?utf-8?B?aTh4bGpPbjRhOWw0RGo2ZUFSMU1id0lJNHF4YkpWSk1rdmVKNDA1Q2hJeFpJ?=
 =?utf-8?B?Z2xLcW9pSGp0SlhaeVVwNGRNTC9sVldteDBBWDcrak5VR0VtL0tyNnk2ZVQx?=
 =?utf-8?B?Z05FUk9XWE43bGRuMEc2MnJ0VENqQWowdmlVRDF3LzhkY1ROUmRRMWg2OUFV?=
 =?utf-8?B?dE1KZStrRnJUNmFuZ24vazZtdjNVRk5hM09VbEJvWFpPYUtBdTFKbVZHYzFQ?=
 =?utf-8?B?QXdTbjM3MWlORVI5dmVNMlk3VW8xeW1CSFFIMXNSbXUxSFUxVHJJbmNqUkxw?=
 =?utf-8?B?bzFGVXhLaDRXNlUyeTRIM0cxMTlHUEwyYy9pRVFyS1J2bkN2dVZRdVo0bUlQ?=
 =?utf-8?B?Vzl5Wml3ZkRWZ2U2OVNwSGs5L2lWZ0ZyU29qWHd1MWZPcUdQS3I5YTNXWGtK?=
 =?utf-8?B?WEVvcDZqM0NhdWJObk9nUGNTdUZtTWhLdExGRUlpeTg0eWsvRmxXemRXZ2xw?=
 =?utf-8?B?UjNIaUNNSUFVb3dsZ1g2V1FPMDBucjV1eEhxS0JVeXdta3RQVGQ1MERCclJT?=
 =?utf-8?B?MHpQdWpCVVFDMXAyUmdJaUJ1WDVKbDhFZ2JvaXB0MXBxVDlHRjNBR21BRmdl?=
 =?utf-8?B?eEs3YnFSdldYdGRyQ0cvQnpqYU11NFZNeHowaVpsQXNqV3M0djFyKzBtdUk1?=
 =?utf-8?B?RjQ1UjBxTTROVDVOS255UUVZNXZ3VjEzZzlSb1pVNy9teXRvN2ZuS1NITjlH?=
 =?utf-8?B?ZGRaNklmbE5ULzY4VnRoMm9Ea2hTeGFvcDBzbXRnQUVuU0t6QWRHSEFWM200?=
 =?utf-8?B?T1NKWkp6UGQ1UGlDMStoZGdmWTMwOFZ4aFdNSTQ0bGJNWDhUcDBGZTR4ODk3?=
 =?utf-8?B?MGN4bm9RanlTdjBnODhnNVJyVDI3ZXEwSmoyamdLMXd1cDMrOXRtRjJEaEtB?=
 =?utf-8?B?M2NKdzF4Y3c0WjN1VDl0blQzakZFM3FUcTVadE1lNmhXRTlvZVJXcStWdFZG?=
 =?utf-8?B?SW90YisvVkk1Z3Rkb2ZPMy9kQ2Y2SDZORWFFV0N4ZDJnTktKTjJkVzJ5Lzgx?=
 =?utf-8?B?UE9DZitLZUlNMDQ5OXNCQ2ptWjBVc0w3aENDN2lBNW1yWUxGTWxZL28ydCtq?=
 =?utf-8?B?cWdaZU5DSEtaQ0UzL2RvdFlXUUZ4VmxRZ0pqQlpza3BoTTFZUTAyNHh5T2JO?=
 =?utf-8?B?VlR1b2M4VGdIbVFuVCszSGNVVGMxb21xV0JyWDBxcjNmTzgyK1BKQVNvYVY1?=
 =?utf-8?B?OXAwN0x5OCs3ZmFta3RkRGhWVHFqdXI4RENnc2RuSDIvQUdyMUk4UTN1Mmlu?=
 =?utf-8?B?YytvM0ZuZXJTZVh6OGRWWFRaMWZReENZbURYVFQrdGo1bC8vVVNXWTRUaUxo?=
 =?utf-8?B?Q2pYMFFsWExDT2tjMmkwbGtXQy9HSGNBY1RJa1V3dXVwMXU3bnVCMXJhTjBY?=
 =?utf-8?B?L2I1dTdmU2luenFVTEdWUENyQXFlR3BSb1VHbXBncllBYUlzbWczZjFmQVdB?=
 =?utf-8?Q?1tCl/NXi8IkEHaq3aUWahsaMl?=
Content-ID: <38D01BB60AEA1A4B9EF50EE89D979A7B@namprd18.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM6PR18MB3667.namprd18.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6cdb3f02-3a87-401e-cf6c-08de1b24360d
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Nov 2025 21:59:07.2291 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5280104a-472d-4538-9ccf-1e1d0efe8b1b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: PZMuItGIZ7D6JDeYlrN7fzMNbwu8g4JyMV+nO4on98hgotOYpLYw/tXt58H2IjWMv7x8iAnk0SVtXXNDQk6H2A==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MW4PR18MB5062
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

PiBTcGlsbGluZyBkZXZpY2UgaXMgYSBwcml2YXRlIGJsb2NrIGRldmljZSB0byBhbiBPU0QgaW4g
THVzdHJlLg0KDQpTaW5jZSB3ZSdyZSBhY2Nlc3NpbmcgdGhlIHNwaWxsIGRldmljZSB2aWEgVkZT
LCBpcyB0aGVyZSBhbnkgcmVxdWlyZW1lbnQNCnRoYXQgdGhlIHNwaWxsIGRldmljZSBpcyBhY3R1
YWxseSBhIGJsb2NrIGRldmljZT8gVGhpcyBjb3VsZCBqdXN0IGJlIGFueQ0KZmlsZXN5c3RlbT8N
Cg0KPiBhbGxvd3MgYW4gT1NEIHRvIG1pZ3JhdGUgaW5mcmVxdWVudGx5IGFjY2Vzc2VkIGRhdGEg
b2JqZWN0cyB0byB0aGlzDQo+IGRldmljZS4gVGhlIGtleSBkaXN0aW5jdGlvbiBiZXR3ZWVuIHBv
cHVsYXIgdGllcmVkIHN0b3JhZ2UgaXMgdGhhdCBpdA0KPiBvbmx5IGhhcyBhIGxvY2FsIHZpZXcg
b2YgdGhlIG9iamVjdHMgaW4gYSBsb2NhbCBPU0QuIENvbnNlcXVlbnRseSwgaXQNCj4gc2hvdWxk
IG1ha2UgcXVpY2sgYW5kIGFjY3VyYXRlIGRlY2lzaW9ucyBiYXNlZCBvbiB0aGUgcmVjZW50IGFj
Y2Vzcw0KPiBwYXR0ZXJuLiBPbmx5IGRhdGEgb2JqZWN0cyBjYW4gYmUgc3BpbGxlZCBpbnRvIHRo
ZSBzcGlsbGluZyBkZXZpY2UsDQo+IHdoaWxlIG1ldGFkYXRhIG9iamVjdHMsIHN1Y2ggYXMgT0kg
bmFtZXNwYWNlIGFuZCBsYXN0IG9iamlkLCByZW1haW4gaW4NCj4gdGhlIE9TRCBwZXJtYW5lbnRs
eS4gVGhpcyBpbXBsaWVzIHRoYXQgdGhlIHNwaWxsaW5nIGRldmljZSBmb3IgT1NEIGlzDQo+IG9u
bHkgYXBwbGljYWJsZSB0byBPU1QgT1NEcy4NCg0KV2XigJlkIG5lZWQgdG8gYWNjb3VudCBmb3Ig
RGF0YS1vbi1NZXRhZGF0YSBhcyB3ZWxsLiBUZWNoaWNhbGx5LCBsbG9ncyBhcmUNCmRhdGEgb2Jq
ZWN0cyBhcyB3ZWxsLiBCdXQgSSBkb3VidCB3ZSdkIHdhbnQgdG8gbWlncmF0ZSB0aG9zZSBvZmYg
dGhlIHByaW1hcnkNCnN0b3JhZ2UuDQoNCj4gR2VuZXJpYyBMdXN0cmUgdXRpbGl0aWVzIHdvbuKA
mXQgYmUgYWJsZSB0byBkaXJlY3RseSBhY2Nlc3Mgc3BpbGxpbmcNCj4gZGV2aWNlcy4gRm9yIGV4
YW1wbGUsICoqbGZzIGRmKiogd2lsbCBvbmx5IGRpc3BsYXkgdGhlIGNhcGFjaXR5IG9mIHRoZQ0K
PiBPU0QgZGV2aWNlLCB3aGlsZSB0aGUgY2FwYWNpdHkgb2YgdGhlIHNwaWxsaW5nIGRldmljZSBj
YW4gYmUgYWNjZXNzZWQNCj4gdXNpbmcgc3BlY2lmaWMgb3B0aW9ucy4NCg0KSSBkb24ndCBzZWUg
d2h5IHRoZXJlIGhhcyB0byBiZSBhIHNlcGFyYXRpb24gYmV0d2VlbiB0aGUgc3BpbGwgZGV2aWNl
DQphbmQgdGhlIE9TRCBkZXZpY2UuIEkgdGhpbmsgaXQncyBhIHNpbXBsZXIgZXhwZXJpZW5jZSBm
b3IgZW5kLXVzZXJzDQppZiB0aGVzZSBkZXRhaWxzIGFyZSBoYW5kbGVkIHRyYW5zcGFyZW50bHku
IElkZWFsbHksIGFsbCBvZiB0aGUgdGllcmluZw0KY29tcGxleGl0eSB3b3VsZCBiZSBoYW5kbGVk
IGJlbG93IHRoZSBPU0QgQVBJIGJvdW5kYXJ5LiBMdXN0cmUgaXRzZWxmDQppLmUuICJ0aGUgdXBw
ZXIgbGF5ZXJzIiBzaG91bGRu4oCZdCBuZWVkIHRvIG1vZGlmaWVkLg0KDQo+IE9TRHMgd2lsbCBh
Y2Nlc3Mgc3BpbGxpbmcgZGV2aWNlcyB0aHJvdWdoIFZGUyBpbnRlcmZhY2VzIGluIHRoZSBrZXJu
ZWwNCj4gc3BhY2UuIFRoZXJlZm9yZSwgdGhlIHNwaWxsaW5nIGRldmljZSBtdXN0IGJlIG1vdW50
YWJsZSBpbnRvIHRoZQ0KPiBrZXJuZWwgbmFtZXNwYWNlLiBJbml0aWFsbHksIG9ubHkgSEREIGlz
IHN1cHBvcnRlZCwgYW5kIHRoZQ0KPiBpbXBsZW1lbnRhdGlvbiBjYW4gYmUgZXh0ZW5kZWQgdG8g
UzMgYW5kIEdDUyB1c2luZyBzM2ZzIGFuZCBnY3NmdXNlDQo+IHJlc3BlY3RpdmVseSBpbiB0aGUg
ZnV0dXJlLg0KDQpUaGlzIGlzbid0IGNsZWFyIHRvIG1lLiBPbmNlIHdlIHN1cHBvcnQgSERELCB3
aGF0IGluY3JlbWVudGFsIHdvcmsNCklzIG5lZWRlZCB0byBzdXBwb3J0IHMzZnMvZ2NzZnVzZS9l
dGM/IEFzIGxvbmcgYXMgdGhleSBwcmVzZW50IGENCm5vcm1hbCBmaWxlc3lzdGVtIEFQSSwgdGhl
eSBzaG91bGQgYWxsIHdvcmsgdGhlIHNhbWU/DQoNClRoaXMgYmVncyB0aGUgcXVlc3Rpb246IGlm
IHdlJ3JlIGFscmVhZHkgZG9pbmcgdGhpcyB3b3JrIHRvIHN1cHBvcnQNCndyaXRpbmcgTHVzdHJl
IG9iamVjdHMgdG8gYW55IGFyYml0cmFyeSBmaWxlc3lzdGVtIHZpYSBWRlMgYW5kIHdlJ3JlIG9u
bHkNCmludGVuZGluZyB0byBzdXBwb3J0IE9TVHMgd2l0aCB0aGlzIHByb3Bvc2FsLCB3aHkgbm90
IGltcGxlbWVudA0KYW4gT1NULW9ubHkgVkZTIE9TRCBhbmQgaGFuZGxlIHRpZXJpbmcgaW4gdGhl
IGZpbGVzeXN0ZW0gbGF5ZXI/DQoNClRoZSBrZXJuZWwgY29tcG9uZW50IHdvdWxkIGJlIG11Y2gg
c2ltcGxlci4gQW5kIHdlJ2QgYmUgYWJsZSB0bw0Kc3VwcG9ydCBhIGxvdCBtb3JlIGNvbXBsZXhp
dHkgaW4gdXNlciBzcGFjZSB3aXRoIEZVU0UuDQoNCklmIHdlIHN0aWxsIHdhbnRlZCB0byBoYW5k
bGUgdGhlIHRpZXJpbmcvbWlncmF0aW9uIGluIGtlcm5lbCBzcGFjZSwNCnRoZW4gYSBWRlMgT1NE
IHdvdWxkIGFsbG93IHVzIHRvIGRvIHRoYXQgcHVyZWx5IHVzaW5nIHRoZSBPU0QNCkFQSXMsIHNp
bWlsYXIgdG8gd2hhdCBBbmRyZWFzIHdhcyBzdWdnZXN0aW5nLg0KDQo+IFRoZXJl4oCZcyBubyBv
bi1kZW1hbmQgbWlncmF0aW9uIGZlYXR1cmUuIElmIHRoZXJl4oCZcyBubyBhdmFpbGFibGUgc3Bh
Y2UNCj4gd2hpbGUgYSBsYXJnZSBjaHVuayBvZiBkYXRhIGlzIGJlaW5nIHdyaXR0ZW4sIHRoZSBz
eXN0ZW0gd2lsbCByZXR1cm4NCj4gRU5PU1BDIHRvIHRoZSBjbGllbnQuIFRoaXMgc2ltcGxpZmll
cyB0aGUgZ3JhbnRpbmcgbWVjaGFuaXNtIG9uIHRoZQ0KPiBPRkQgc2lnbmlmaWNhbnRseS4gQW5v
dGhlciByZWFzb24gZm9yIHRoaXMgYXBwcm9hY2ggaXMgdGhhdCB3cml0aW5nDQo+IHBlcmZvcm1h
bmNlIGlzIG1vcmUgcHJlZGljdGFibGUuIE90aGVyd2lzZSwgdGhlIHN5c3RlbSBtaWdodCBoYXZl
IHRvDQo+IHdhaXQgZm9yIGFuIG9iamVjdCB0byBiZSBtaWdyYXRlZCBvbiBkZW1hbmQsIGxlYWRp
bmcgdG8gbXVjaCBoaWdoZXINCj4gbGF0ZW5jeS4NCg0KSSB0aGluayB1c2VycyB3b3VsZCB0b2xl
cmF0ZSBzbG93IGpvYnMgbW9yZSB0aGFuIHdyaXRlIGZhaWx1cmVzIGJlY2F1c2UNCnRoZSBPU0Qg
aXNuJ3Qgc21hcnQgZW5vdWdoIHRvIHdyaXRlIHRvIHRoZSBlbXB0eSBzcGlsbCBkZXZpY2UuDQoN
Cj4gIyMgQ29uY2x1c2lvbg0KPg0KPiBUaGlzIHNvbHV0aW9uIGdpdmVzIGEgcG9zc2libGUgc29s
dXRpb24gdHJ5aW5nIHRvIGFkZHJlc3MgdGhlDQo+IHBhaW5wb2ludHMgb2YgcHJldmFsZW50IHRp
ZXJlZCBzdG9yYWdlIHVzaW5nIG1pcnJvcmluZywgd2hlcmUgYQ0KPiBmdWxsLWZsYXZvdXJlZCBw
b2xpY3kgZW5naW5lIGhhcyB0byBydW4gb24gZGVkaWNhdGVkIGNsaWVudHMsIGFuZA0KDQpUaGUg
Y2xpZW50IHN0aWxsIGhhcyB0byBkbyBzb21lIG1hbnVhbCBtYW5hZ2VtZW50PyBpLmUuIHlvdSBj
YW4ndA0Kd3JpdGUgaW5kZWZpbml0ZWx5IC0gdGhlIGNsaWVudCB3b3VsZCBoYXZlIHRvIHBlcmlv
ZGljYWxseSBmb3JjZSBhIHdyaXRlDQp0byB0aGUgc3BpbGwgZGV2aWNlIG9yIGl0IG1pZ2h0IGhp
dCBFTk9TUEM/IFRoaXMgaXMgYmV0dGVyIHRoYW4gdGhlDQpwYWluIG9mIG1hbnVhbGx5IG1hbmFn
aW5nIG1pcnJvcnMsIGJ1dCBpdCdzIG5vdCBhIGNvbXBsZXRlIHNvbHV0aW9uLg0KDQo+IGRlbGl2
ZXIgYmV0dGVyIHBlcmZvcm1hbmNlIHRoYW4gYmxvY2stbGV2ZWwgY2FjaGUgd2l0aCBkbWNhY2hl
LCB3aGVyZQ0KPiByZWNvdmVyeSB0aW1lIGlzIGxlbmd0aHkgaWYgdGhlIGNhY2hlIHNpemUgaXMg
aHVnZS4NCg0KVGhpcyBzZWVtcyBzcGVjdWxhdGl2ZS4gQ291bGQgeW91IGVsYWJvcmF0ZSBtb3Jl
IG9uIHdoeSB5b3UgdGhpbmsNCnRoaXMgaXMgdGhlIGNhc2U/DQoNCl9fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QK
bHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcKaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlz
dGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnCg==
