Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9D84AC677C4
	for <lustre-devel@archiver.kernel.org>; Wed, 11 Jun 2025 00:38:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4bH69v69jBz239j;
	Tue, 10 Jun 2025 17:34:43 -0700 (PDT)
Received: from outbound-ip168a.ess.barracuda.com
 (outbound-ip168a.ess.barracuda.com [209.222.82.36])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4bH68r6vR3z1xP1; Tue, 10 Jun 2025 17:33:48 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com
 (mail-sn1nam02on2120.outbound.protection.outlook.com [40.107.96.120]) by
 mx-outbound-ea9-35.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Wed, 11 Jun 2025 00:33:44 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=V3cDpAko3b6nce9l+G+XdefqY3tZjkT3zhwkBpTBJnnNCEW5hcEDij4Ws80vg6ZYwN2WqaJ/QSCuTe1M1hhqW+4briCgb4nURo+lLKWzSFk+8NYawlWErl6syoIWml7es0na+cyyA2W2lU9IdJExRJ/DqQF/UvAsqjqiqM40LH9YGTNvOQ4A9f2iq6L/NadWgvytVUYzvPWrqQyBTH9UqZ6HIP6vz/V1K5gsmr1wKTe7V92jmrLOVxbxOrwWdtz5o5bM7K4Gj3RkX1Pd8qBWpcUJpSBK/J4g4hpA8NKqQjljMXXdUGTB7KhqIfMk41aYJC7pmMRt90k8Nlzy4UEDag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=6en4msoSAii6KDr8rB+QxXG4mYRQ/phbGIwMnmhnObM=;
 b=j6ODXkfLbunp3IME8I+mmlwrw8WOrrcxQLpS3eyduu9/gBbF4R5mCZyE/BDZxphppPI9KW2egIWmNByTkXgJkJl+DD0qqjHcYq17F9A/0Shg6rtderU9qvUZT9gTp0zSuca6XT/dkPhqShTnoTZSRAG5fZANtaCIQ3691IiRfWCQ7gKyvrjug9hIP3muWTNc2i0wiwPMx1MQwYrRQYm4sbdv8EmASeiiqRORWLkj5HxqoNjwy2uTpMuISH5icRSWuebCneB2bENL1YH9onXHCK1U0QlCfBA7qBlIuacdPDpgKyBUTsGDmvO7HIEUFKE9knche1JIvipnnK9mspdLhQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=6en4msoSAii6KDr8rB+QxXG4mYRQ/phbGIwMnmhnObM=;
 b=U5q3a1Kx2fPPGlvcewM88Y/xi6OUoVQjiNMmGXf8EOe1KxowuuKR8OuooAe76wdMLBC9po7flIspz6wUSrh6bzpRHQHvw0V0LaK7SFe8mW05Bf76IrV22LQSrVsiyFasn6xvsRCOQBIyIN9RGegmFukX8EAtdG4anKBw/FyYotI=
Received: from MW4PR19MB6674.namprd19.prod.outlook.com (2603:10b6:303:1e8::21)
 by SJ0PR19MB6838.namprd19.prod.outlook.com (2603:10b6:a03:449::5)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8835.16; Wed, 11 Jun
 2025 00:33:21 +0000
Received: from MW4PR19MB6674.namprd19.prod.outlook.com
 ([fe80::44e6:e287:b3a5:eb0a]) by MW4PR19MB6674.namprd19.prod.outlook.com
 ([fe80::44e6:e287:b3a5:eb0a%3]) with mapi id 15.20.8835.012; Wed, 11 Jun 2025
 00:33:21 +0000
From: Peter Jones <pjones@whamcloud.com>
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
 "lustre-announce@lists.lustre.org" <lustre-announce@lists.lustre.org>,
 "lwg@lists.opensfs.org" <lwg@lists.opensfs.org>, lustre-discuss
 <lustre-discuss-bounces@lists.lustre.org>
Thread-Topic: Lustre 2.15.7 released
Thread-Index: AQHbxaaJw0nzvTWH+02/8INQF30GTA==
Date: Wed, 11 Jun 2025 00:33:20 +0000
Message-ID: <AF46A743-1612-4659-A12A-E493EF4DF537@whamcloud.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/16.97.25051114
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB6674:EE_|SJ0PR19MB6838:EE_
x-ms-office365-filtering-correlation-id: de132079-7cda-42be-7b8e-08dda87f915c
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|366016|1800799024|376014|8096899003|13003099007|38070700018; 
x-microsoft-antispam-message-info: =?utf-8?B?QThDMmRBRzVFM2ZHQ1p3UnJ1a1RnWk0zMnNnZ3ZlNWRJNDBSUjkwWkVrZGp2?=
 =?utf-8?B?MjE3Sm1wdFZLdFB3YmVhR056NXRzUGhLTy9oazZ3OEMvdzllV2hyM1BOR1B5?=
 =?utf-8?B?aWd2Tzk4azAyZjJCVUprcCs0RmRaRzlocEYwaHJEOEx0RXhXNmJBUHNxYVF2?=
 =?utf-8?B?b1RaMk91MDhqZG1Jb3ZoMEVibDFSd1l3MEVEbzlpRG5MRTFZd1B6OVJScHpk?=
 =?utf-8?B?b3FDaStaTFA5dC85MXpGYWVndHRJaHJVVW5IZE1oV2dBL3cxOUZFZFlTV0d3?=
 =?utf-8?B?cGtDS0c2K05ZbXBaNlBSYk9qaVBtSU0xL3ppbEozaWRzSTdlOGpmdWVHdldJ?=
 =?utf-8?B?OXBSU1IyRXl1RkU4S2V1M0sxN3VjaDBGcDVwd1N4cGowWVhTb3NWem1halBI?=
 =?utf-8?B?V2RlaElkYTJLUy9LRW1aS1NWWGFZNmlUaDVGMTc4a0N0SHhGWHZSQUVsZFdK?=
 =?utf-8?B?MU9rUDBZMVlCbmtWVmdZZWRSV0JpQSsxcnJwcFB4Rk1QOHVvdWRSblBNcEQ3?=
 =?utf-8?B?RTh1TFJFL0IyVjdjWmhsR1hiUk5TcC92L1hMNjBFL1ZYUWkwUGhtRTEreDJ2?=
 =?utf-8?B?bW9XNStpQmh5MDZQUTVwcU9CK2VhZ2Jiek5HMGRaTXpORzdCKzgzSVg2aEFR?=
 =?utf-8?B?ait5bUJwME5kNExKRWRyZG9FOVE0UWZyM1lNQ0NQL2dTVFp4SVZXeGgzaXk4?=
 =?utf-8?B?NUxDUFV6bzgya2xyM3dKWWluOUpXUkRuRjkwZlJMNjhzQmhBMU0yM2swTzJH?=
 =?utf-8?B?d3J1YVF0Um1xNVFuS3k0WVExdytVUjYrTExjcitRQnNmeXd6eWVleHcrakNO?=
 =?utf-8?B?Q25Xa2grVFhKUCtxOWcrQ2c0clNLZFhxa0pQTXM2dFFzZjRCcFFIZ0dQUk1i?=
 =?utf-8?B?NlIyUTlKTHY0bnFQRHpKU1hrbXpEZU50RnFxRkJIYTJIOFJUZHhwb1Y5T0t0?=
 =?utf-8?B?ajNyKzAzckQ4S0lYcTFsNm5CYm1ONDhScCt6dUxVU1JMVEtVeFBYczJqTTYr?=
 =?utf-8?B?VTMwUldGeERRczZ4OEZ6cXF5dXRBQzA1emczVWpMWlFjbDh4K3V0NER1NEJG?=
 =?utf-8?B?VTc2TWM3cVp4bDFnSy9CWTBia1lqWkVldHNNaUFFMkR5RGszdkc3UjlxU3pW?=
 =?utf-8?B?NTh2a0ZSTDcyMUYxbFVCSHN4UDhoenExaTBsaHU1UUY5TEZoL3FWbmJJMVhl?=
 =?utf-8?B?Y0ZaOWlPT3poeG9vMWdKbHBVaFNSbjFqWFE3NTg5VmwwNXVmbk9VVVBHR2hU?=
 =?utf-8?B?ZjZiNTY0U2hoa0Q4cVl4RjJpL1Q3Tk9weXk1dkhhbkhQMGRVZEJsYmhrWlUw?=
 =?utf-8?B?bWN1eko4MTlzN3dhLysxeHhuK2FJV2FKWE5kWGNPRWFaa0p1dHVBeXZpM0Mx?=
 =?utf-8?B?bXVvWkU3b1EzYTRqQlBxMGdVamI5alFCc01FWDlYenl4WHdNQ0w3TndMSlI3?=
 =?utf-8?B?aEZuS080SG4xZlRzRjZERmdiejk1bHVNZFhYS0lyNVhpOHhqTktZNnFhVUl4?=
 =?utf-8?B?eHNQUHJiOWIxcE1MaVRDSmk0SnJ0bERrYnNESTc0UkYxekIyMC9Pd3NVL3RX?=
 =?utf-8?B?Rm5TOVJ4WWFNSFVpOHZ1dnpneXp6S25uTzhHWURRdEZjQWpuaGFXcEw0WXFT?=
 =?utf-8?B?RUlEbEE0M2VtcFJITGtIWS9RUjlST3NEZVVKUmZJb2xTS1ZXeGtNM25PVitS?=
 =?utf-8?B?Qk5kWVlNYjc2eHd0dGZuTzNLeThXbW8yVHE0OHZIcld3QVZmYUhHK2ZMNXNx?=
 =?utf-8?B?QVRuczB1Q3FQL2RwNjc1Ly9BUFZYYTNkQW82UHBDdFpEcTE1bkNld0ZERkdS?=
 =?utf-8?B?c0ExWmpoUmdGM1BLMkM1bzVCV0xOcjR1Sit1cWxnc21OYTkvNGE1RDZmbFNH?=
 =?utf-8?B?OGt4clBvSXBHRW9oaDdKTUVFZXZSUlZQaklsQjBIV1ZyQXo5Tk5iemlmZVov?=
 =?utf-8?Q?QBoy51wcisE=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB6674.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(376014)(8096899003)(13003099007)(38070700018);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?L2Z0eDRZUlZBNmV4T0VRODFVbW41eFZNN3R1UUJUTUdSTE1nVndHakFGd3VD?=
 =?utf-8?B?TEwrelRML1dBY09rcG13QTFEM3NzQ1FtM3pFaURHeXgxbWdQc0l1TXNlQlh4?=
 =?utf-8?B?UURxbkdZZEdIckNIeUlWa3V1WHZHUCtyNlpYT2s5NXYreUVOcHJ6TzRWTnlX?=
 =?utf-8?B?QUZBcFZVdkkwQWdMT3lDaFVONnBpNWtUTEpGT3locDBoRG9Jd3g5SFcwejhy?=
 =?utf-8?B?cGRSQnZNSGVjeUNEOEw3dlZEVE1tbmhoUktOczVYL2lzaGFreFNyMVBxUGdW?=
 =?utf-8?B?THpVT2tHb2FxUms1VTVja0FacDlWZzZJK1FXMDJsMXRxSFhwQ0lweEtDSC8x?=
 =?utf-8?B?bHE1VGRlN0FQOXRXalBSUjB0VXpJZUhFZzRsWlV4dXd1TER1SmE0NC91R1dx?=
 =?utf-8?B?QmJDRTNkWDhUcDNSZXoyZGVPSnBFaHVDVjNxcVl4bkxQK3FCMWE5MFM4b1R3?=
 =?utf-8?B?RCswRWdPdTN4MCtNVU9hZTNiR3IwKzNrazBvL25MeElWUVk1bmVWWUhqVWdH?=
 =?utf-8?B?TlRSMFJ4amZrT2R5Q3hmM1N6OVRVbnhWdTZuMHlEcnR1cExkS2NqbU1mYWNx?=
 =?utf-8?B?YnJDYkQ5WlB2WE1LMnFqQVBFTG5WYlVRR2RhZjNPYmp0Z0ZaaElkOHJpSVN4?=
 =?utf-8?B?SnNGOHBFb0JmVnREKzB6eUJXNHRTS1pzTlVHMmVhKzJhczJ1YjRMWE9ybEd1?=
 =?utf-8?B?dWJ3VC8wV0k2WWt4c0hCNjJTT2djZjliVGFGenRaVDBVb0xYMnZNaGpJVU1t?=
 =?utf-8?B?SFQ4ZGl2d0p2OWFrRUZzdDZPcTVYakhEYmQ5MzhNWjgvSHdMWEl5bE8vaTV0?=
 =?utf-8?B?b2xLVFVNNGRXV2M2TGE5a21jNlF3cUdNNTRMWm55VHQ3VTVram1wNVVxS0p3?=
 =?utf-8?B?Tk5XWjc2dkFRS1dnZ2cwMVd5aUswTXl0T3pMQ0JyQzZhd0UyNWJXOGVjZk1x?=
 =?utf-8?B?QlVDSDYxTGU2S0p5YTNSZWJvV1NKRno5STJ4VGNON1Y1ckk5SnlLUGJrUjZP?=
 =?utf-8?B?enlvbE5kc1N4MXBwLzNJbHdzZmJuMGRmSVBjYk1QNTJtUHNhdllKcHU2b2xR?=
 =?utf-8?B?RVV2a2lBNGZYWDlaRG5IRjQvZWhUcElscFlFUlZTN0ZETUhCRHFjVzYrbXFT?=
 =?utf-8?B?Z1FkaVpIRFdXcEFHU1VYVldsSDdlUStvQlp3eGdncmdDbUt2QzNzcDVqOFdM?=
 =?utf-8?B?cmk0UTYraFUyM1hpWXZwdGZpeGJwMVZocTlEeEVYeU1tbXpMUUprUXg4SlBC?=
 =?utf-8?B?KytuUGs2WktyK2ZwNWlUblE1ckExMFFHNzVJQzE2Q2VLQTNoSkFxRDdzSXJX?=
 =?utf-8?B?K2tzZWZRZFFQclVZL2lOdkNlTXo2L1JhM0llWTY3d21wcXRJQ1dlaGt4eWYx?=
 =?utf-8?B?d1hOck41Rk5ZWmFPaTBtYTFNLzlpRFVqWXc0UGdhWWVVUVIzeS9oY0w4dTR2?=
 =?utf-8?B?eTh4ZWZWUnI1V1ZWM1lHbDB6blFpWkJLSkJ3aDN6VUc4ZjJMcmNFczF2Tkdq?=
 =?utf-8?B?R1dYM1p1N3FETUdVTU5GVWh2UkpseVh2UmdHYlMyVGdNMmgrd3ZtTkxDNjh1?=
 =?utf-8?B?Z0swSGFtN1lmem9tNGpRa3NybHFXMjRKTUxJQ296bi9ua0lSN1VjdENON3J0?=
 =?utf-8?B?RWs0T25CcG5MYjJYWkduMTQxdXBGRnFSL2dYVWhBRjlFWlVvMDluUlp1ZTd6?=
 =?utf-8?B?b1dEanJhb28xN2wrK21kVGJuN0FOTzhlT3B3U3d4WEdCU0ZjVDM2c0FDZ2FO?=
 =?utf-8?B?SC9hbFBQUTJsNENGOWFwSFlJY2RIRzlsTC9yRFVlb08yMjFVT3gwbk5wbzNj?=
 =?utf-8?B?Rjl0N0VnVTh6YzBTY0t2UEtCeC9zT041R29xL2JsdFNZZ0RLc3QrYTJ6YW9H?=
 =?utf-8?B?OGVJaGdhTkFvY3JtZWVsbkFVVWgxRWpQaHREdjhXSXUrdEU0bmdSUjFNRVNo?=
 =?utf-8?B?VzlNeDNwUWdxdEQ3R284N2ZYRG9RdkJCM0s3bHN5Mkt6SXBzSXV5SXg5V1Ax?=
 =?utf-8?B?dVJETjdIMGpmOEszaVV4NzltY3R4Y0JFNW9OWmhOSFFNUDRVbGpPSG1Hbm1O?=
 =?utf-8?B?eFVHT3dZcDVxN0VLWVJObXNYSmVlNFVQeEFMQ3JMZTlLSVluMm5aeFRZc3J5?=
 =?utf-8?Q?ERI/B106pmUYDjy5Vy5MV4Occ?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: Qc+rKv59buKECcI8msnF8Raq/ZcXfCw37mWW2HhCiLMaRjyGPszbqTA3dSgWbGl5HFnXguIa2x6MO9P3mQx9tYY4Fxyq0A6cC6SE+sUO9tLC7kHE5w0UQ1IPucZ+QE9fi41rlK5xwyKIMKe3EBdsCtqgHL/BjUIHHJx2cbWXMN9T9V0deSwt9rM0cBPXTWrLb7/2sYICnFO3FUU3VvjhcH5yw2pe+5FwBAJwVch5Ow5sxhmSHtKqMmb7qtIH7OtwKYxxi5X3QCCPaYbs+mL+14WuJyxNg2wYza7I2bUhqoIJxK7hpLKqcerHn0oslwteDVn3WXK/5EPuM61lf0oO169EWMF7D+He0+om8JD6tteaMe/eGuxR0qBaOkbM9kUmq325q74AeWLHVrVG5SK67p7D/bbG7JMLkzz0+jDUAdHvKcZG6DYEavsKMOqgSzXhKWLLVFl9iKnpaWNFiqQQPtwLgetiGUB0WfdG8I8dT7ul72YXqITy9OyrWlsluuYhLt7BSLkppBGiHa0sKm0VPAogc0Sik8vpYrsAeFz/9NEzZE2bgPN1db8vB6qTnJWev0vsgZ0HyMsYw28zII6/NuHVrpSh3UuewAXd6XhxWf+H1fpSNX3c4/Tx2klsMepSl3UOoJ4DCyVsuYSBg2Icn675qTYNYwnGlmWLlmTY4mg=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB6674.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: de132079-7cda-42be-7b8e-08dda87f915c
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Jun 2025 00:33:20.9511 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: EXH5lF4I8JGCCNyBH3GxMD9TWWv5+CvZW5Qyb3NaA1QDgb3tNG3IMjJRLjVm3Xdf
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ0PR19MB6838
X-BESS-ID: 1749602024-102339-21980-13593-1
X-BESS-VER: 2019.3_20250609.1526
X-BESS-Apparent-Source-IP: 40.107.96.120
X-BESS-Parts: H4sIAAAAAAACAzXLsQ7DIAyE4XfxnMGYw+C8StWBEKMsVYcyVKry7mVIltOvk7
 7Hj/w7aKUxd6H3h1YzmXHMzxqHqgDYoM3ZQlbfmgv2mKKBzuXmx3hdXCG3j9K15ArtAs
 689QKUPXlJXT3UQOfzD8WVut+AAAAA
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.265245 [from 
 cloudscan19-42.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: [lustre-devel] Lustre 2.15.7 released
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
Content-Type: multipart/mixed; boundary="===============4378211364115739603=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============4378211364115739603==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_AF46A74316124659A12AE493EF4DF537whamcloudcom_"

--_000_AF46A74316124659A12AE493EF4DF537whamcloudcom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

V2UgYXJlIHBsZWFzZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTUuNyBSZWxlYXNl
IGhhcyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yIGRvd25sb2FkPGh0dHBz
Oi8vZG93bmxvYWRzLndoYW1jbG91ZC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUtMi4xNS43Lz4g
PGh0dHBzOi8vZG93bmxvYWRzLmhwZGQuaW50ZWwuY29tL3B1YmxpYy9sdXN0cmUvbHVzdHJlLTIu
MTEuMC8+IC4gWW91IGNhbiBhbHNvIGdyYWIgdGhlIHNvdXJjZSBmcm9tIGdpdDxodHRwczovL2dp
dC53aGFtY2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNlLmdpdDthPWNvbW1pdDtoPTE4MzRj
OTE1ZGZlMWMzNmIwZTQ5NTE4OTFmNmJkNThmMjAxZWRjYzU+DQoNCkRldGFpbHMgb2YgY2hhbmdl
cyBzaW5jZSAyLjE1LjY8aHR0cHM6Ly93aWtpLmx1c3RyZS5vcmcvTHVzdHJlXzIuMTUuNl9DaGFu
Z2Vsb2c+IGNhbiBiZSBmb3VuZCBpbiB0aGUgMi4xNS43IGNoYW5nZSBsb2cuPGh0dHBzOi8vd2lr
aS5sdXN0cmUub3JnL0x1c3RyZV8yLjE1LjdfQ2hhbmdlbG9nPg0KDQpUaGUgZm9sbG93aW5nIGFy
ZSBub3RhYmxlIGNoYW5nZXMgc2luY2UgMi4xNS42Og0KDQpSSEVMIDkuNiBpcyBub3cgc3VwcG9y
dGVkIGZvciBjbGllbnRzICAgKExVLTE4NjY4PGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jy
b3dzZS9MVS0xODY2OD4pDQoNClNMRVMxNSBTUDYgaXMgbm93IHN1cHBvcnRlZCBmb3IgY2xpZW50
cyAgIChMVS0xODY2ODxodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS9icm93c2UvTFUtMTg2Njg+
KQ0KDQpQbGVhc2UgbG9nIGFueSBpc3N1ZXMgZm91bmQgaW4gdGhlIGlzc3VlIHRyYWNraW5nIHN5
c3RlbTxodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS8+Lg0KDQpUaGFua3MgdG8gYWxsIHRob3Nl
IHdobyBoYXZlIGNvbnRyaWJ1dGVkIHRvIHRoZSBjcmVhdGlvbiBvZiB0aGlzIHJlbGVhc2UuDQoN
ClRoZSBuZXh0IExUUyByZWxlYXNlIHdpbGwgYmUgMi4xNS44DQoNCg==

--_000_AF46A74316124659A12AE493EF4DF537whamcloudcom_
Content-Type: text/html; charset="utf-8"
Content-ID: <B55E771F96CF404483A0277C4C4CFF43@namprd19.prod.outlook.com>
Content-Transfer-Encoding: base64

PGh0bWwgeG1sbnM6bz0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTpvZmZpY2U6b2ZmaWNlIiB4
bWxuczp3PSJ1cm46c2NoZW1hcy1taWNyb3NvZnQtY29tOm9mZmljZTp3b3JkIiB4bWxuczptPSJo
dHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL29mZmljZS8yMDA0LzEyL29tbWwiIHhtbG5zPSJo
dHRwOi8vd3d3LnczLm9yZy9UUi9SRUMtaHRtbDQwIj4NCjxoZWFkPg0KPG1ldGEgaHR0cC1lcXVp
dj0iQ29udGVudC1UeXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7IGNoYXJzZXQ9dXRmLTgiPg0KPG1l
dGEgbmFtZT0iR2VuZXJhdG9yIiBjb250ZW50PSJNaWNyb3NvZnQgV29yZCAxNSAoZmlsdGVyZWQg
bWVkaXVtKSI+DQo8c3R5bGU+PCEtLQ0KLyogRm9udCBEZWZpbml0aW9ucyAqLw0KQGZvbnQtZmFj
ZQ0KCXtmb250LWZhbWlseToiQ2FtYnJpYSBNYXRoIjsNCglwYW5vc2UtMToyIDQgNSAzIDUgNCA2
IDMgMiA0O30NCkBmb250LWZhY2UNCgl7Zm9udC1mYW1pbHk6Q2FsaWJyaTsNCglwYW5vc2UtMToy
IDE1IDUgMiAyIDIgNCAzIDIgNDt9DQpAZm9udC1mYWNlDQoJe2ZvbnQtZmFtaWx5OkFwdG9zOw0K
CXBhbm9zZS0xOjIgMTEgNiA0IDIgMiAyIDIgMiA0O30NCi8qIFN0eWxlIERlZmluaXRpb25zICov
DQpwLk1zb05vcm1hbCwgbGkuTXNvTm9ybWFsLCBkaXYuTXNvTm9ybWFsDQoJe21hcmdpbjowaW47
DQoJZm9udC1zaXplOjEyLjBwdDsNCglmb250LWZhbWlseToiQ2FsaWJyaSIsc2Fucy1zZXJpZjt9
DQphOmxpbmssIHNwYW4uTXNvSHlwZXJsaW5rDQoJe21zby1zdHlsZS1wcmlvcml0eTo5OTsNCglj
b2xvcjojMDU2M0MxOw0KCXRleHQtZGVjb3JhdGlvbjp1bmRlcmxpbmU7fQ0Kc3Bhbi5hcHBsZS1j
b252ZXJ0ZWQtc3BhY2UNCgl7bXNvLXN0eWxlLW5hbWU6YXBwbGUtY29udmVydGVkLXNwYWNlO30N
Ci5Nc29DaHBEZWZhdWx0DQoJe21zby1zdHlsZS10eXBlOmV4cG9ydC1vbmx5Ow0KCWZvbnQtc2l6
ZToxMC4wcHQ7DQoJbXNvLWxpZ2F0dXJlczpub25lO30NCkBwYWdlIFdvcmRTZWN0aW9uMQ0KCXtz
aXplOjguNWluIDExLjBpbjsNCgltYXJnaW46MS4waW4gMS4waW4gMS4waW4gMS4waW47fQ0KZGl2
LldvcmRTZWN0aW9uMQ0KCXtwYWdlOldvcmRTZWN0aW9uMTt9DQotLT48L3N0eWxlPg0KPC9oZWFk
Pg0KPGJvZHkgbGFuZz0iRU4tVVMiIGxpbms9IiMwNTYzQzEiIHZsaW5rPSIjOTU0RjcyIiBzdHls
ZT0id29yZC13cmFwOmJyZWFrLXdvcmQiPg0KPGRpdiBjbGFzcz0iV29yZFNlY3Rpb24xIj4NCjxw
IGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+V2UgYXJlIHBsZWFz
ZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTwvc3Bhbj41PHNwYW4gc3R5bGU9ImNv
bG9yOmJsYWNrIj4uPC9zcGFuPjc8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPiBSZWxlYXNlIGhh
cyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yJm5ic3A7PC9zcGFuPjxhIGhy
ZWY9Imh0dHBzOi8vZG93bmxvYWRzLndoYW1jbG91ZC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUt
Mi4xNS43LyI+ZG93bmxvYWQ8L2E+PGEgaHJlZj0iaHR0cHM6Ly9kb3dubG9hZHMuaHBkZC5pbnRl
bC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUtMi4xMS4wLyI+Jm5ic3A7PC9hPjxzcGFuIHN0eWxl
PSJjb2xvcjpibGFjayI+Lg0KIFlvdSBjYW4gYWxzbyBncmFiIHRoZSBzb3VyY2UgZnJvbTwvc3Bh
bj48YSBocmVmPSJodHRwczovL2dpdC53aGFtY2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNl
LmdpdDthPWNvbW1pdDtoPTE4MzRjOTE1ZGZlMWMzNmIwZTQ5NTE4OTFmNmJkNThmMjAxZWRjYzUi
PiZuYnNwO2dpdDwvYT48c3BhbiBsYW5nPSJFTi1DQSI+PG86cD48L286cD48L3NwYW4+PC9wPg0K
PHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3Nw
YW4+PHNwYW4gbGFuZz0iRU4tQ0EiPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJN
c29Ob3JtYWwiIHN0eWxlPSJtYXJnaW4tcmlnaHQ6LjVpbiI+PHNwYW4gc3R5bGU9ImNvbG9yOmJs
YWNrIj5EZXRhaWxzIG9mIGNoYW5nZXMgc2luY2UmbmJzcDs8L3NwYW4+PGEgaHJlZj0iaHR0cHM6
Ly93aWtpLmx1c3RyZS5vcmcvTHVzdHJlXzIuMTUuNl9DaGFuZ2Vsb2ciIHRpdGxlPSJodHRwczov
L3dpa2kubHVzdHJlLm9yZy9MdXN0cmVfMi4xMi44X0NoYW5nZWxvZyI+PHNwYW4gc3R5bGU9ImNv
bG9yOndpbmRvd3RleHQiPjIuMTUuNjwvc3Bhbj48L2E+PHNwYW4gY2xhc3M9ImFwcGxlLWNvbnZl
cnRlZC1zcGFjZSI+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PC9zcGFu
PjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+Y2FuDQogYmUgZm91bmQgaW4gdGhlJm5ic3A7PC9z
cGFuPjxhIGhyZWY9Imh0dHBzOi8vd2lraS5sdXN0cmUub3JnL0x1c3RyZV8yLjE1LjdfQ2hhbmdl
bG9nIj48c3BhbiBzdHlsZT0iY29sb3I6d2luZG93dGV4dCI+Mi4xNS43IGNoYW5nZSBsb2cuPC9z
cGFuPjwvYT48c3BhbiBsYW5nPSJFTi1DQSIgc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQ7Y29sb3I6
YmxhY2siPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiIHN0eWxl
PSJjYXJldC1jb2xvcjogcmdiKDAsIDAsIDApO2ZvbnQtdmFyaWFudC1jYXBzOiBub3JtYWw7b3Jw
aGFuczogYXV0bzt0ZXh0LWFsaWduOnN0YXJ0O3dpZG93czogYXV0bzstd2Via2l0LXRleHQtc2l6
ZS1hZGp1c3Q6IGF1dG87LXdlYmtpdC10ZXh0LXN0cm9rZS13aWR0aDogMHB4O3dvcmQtc3BhY2lu
ZzowcHgiPg0KPHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PHNwYW4gbGFu
Zz0iRU4tQ0EiIHN0eWxlPSJjb2xvcjpibGFjayI+PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAg
Y2xhc3M9Ik1zb05vcm1hbCIgc3R5bGU9ImNhcmV0LWNvbG9yOiByZ2IoMCwgMCwgMCk7Zm9udC12
YXJpYW50LWNhcHM6IG5vcm1hbDtvcnBoYW5zOiBhdXRvO3RleHQtYWxpZ246c3RhcnQ7d2lkb3dz
OiBhdXRvOy13ZWJraXQtdGV4dC1zaXplLWFkanVzdDogYXV0bzstd2Via2l0LXRleHQtc3Ryb2tl
LXdpZHRoOiAwcHg7d29yZC1zcGFjaW5nOjBweCI+DQo8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2si
PlRoZSBmb2xsb3dpbmcgPC9zcGFuPmFyZSA8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPm5vdGFi
bGUNCjwvc3Bhbj5jaGFuZ2VzPHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4gPC9zcGFuPnNpbmNl
PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4gMi4xNS48L3NwYW4+NjxzcGFuIHN0eWxlPSJjb2xv
cjpibGFjayI+Ojwvc3Bhbj48c3BhbiBsYW5nPSJFTi1DQSIgc3R5bGU9ImNvbG9yOmJsYWNrIj48
bzpwPjwvbzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIiBzdHlsZT0iY2FyZXQt
Y29sb3I6IHJnYigwLCAwLCAwKTtmb250LXZhcmlhbnQtY2Fwczogbm9ybWFsO29ycGhhbnM6IGF1
dG87dGV4dC1hbGlnbjpzdGFydDt3aWRvd3M6IGF1dG87LXdlYmtpdC10ZXh0LXNpemUtYWRqdXN0
OiBhdXRvOy13ZWJraXQtdGV4dC1zdHJva2Utd2lkdGg6IDBweDt3b3JkLXNwYWNpbmc6MHB4Ij4N
CjxiPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjaztiYWNrZ3JvdW5kOndoaXRlIj4mbmJzcDs8L3Nw
YW4+PC9iPjxzcGFuIGxhbmc9IkVOLUNBIiBzdHlsZT0iZm9udC1zaXplOjE0LjBwdDtjb2xvcjpi
bGFjayI+Jm5ic3A7PC9zcGFuPjxzcGFuIGxhbmc9IkVOLUNBIj48bzpwPjwvbzpwPjwvc3Bhbj48
L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48Yj48c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPlJI
RUwgOS48L3NwYW4+NjwvYj48c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPg0KPHNwYW4gc3R5bGU9
ImJhY2tncm91bmQ6d2hpdGUiPmlzIG5vdyBzdXBwb3J0ZWQgZm9yIGNsaWVudHM8c3BhbiBjbGFz
cz0iYXBwbGUtY29udmVydGVkLXNwYWNlIj4mbmJzcDs8L3NwYW4+PC9zcGFuPiZuYnNwOyAoPC9z
cGFuPjxhIGhyZWY9Imh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jyb3dzZS9MVS0xODY2OCI+
PHNwYW4gc3R5bGU9ImNvbG9yOndpbmRvd3RleHQiPkxVLTE4NjY4PC9zcGFuPjwvYT48c3BhbiBz
dHlsZT0iY29sb3I6YmxhY2siPik8bzpwPjwvbzpwPjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNv
Tm9ybWFsIj48c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPjxvOnA+Jm5ic3A7PC9vOnA+PC9zcGFu
PjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxiPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+
U0xFUzE1IFNQNjwvc3Bhbj48L2I+PHNwYW4gY2xhc3M9ImFwcGxlLWNvbnZlcnRlZC1zcGFjZSI+
PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PC9zcGFuPjxzcGFuIHN0eWxl
PSJjb2xvcjpibGFjaztiYWNrZ3JvdW5kOndoaXRlIj5pcyBub3cgc3VwcG9ydGVkIGZvciBjbGll
bnRzPHNwYW4gY2xhc3M9ImFwcGxlLWNvbnZlcnRlZC1zcGFjZSI+Jm5ic3A7PC9zcGFuPjwvc3Bh
bj48c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPiZuYnNwOw0KICg8L3NwYW4+PGEgaHJlZj0iaHR0
cHM6Ly9qaXJhLndoYW1jbG91ZC5jb20vYnJvd3NlL0xVLTE4NjY4IiB0aXRsZT0iaHR0cHM6Ly9q
aXJhLndoYW1jbG91ZC5jb20vYnJvd3NlL0xVLTE4NjY4Ij5MVS0xODY2ODwvYT48c3BhbiBzdHls
ZT0iY29sb3I6YmxhY2siPik8L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4g
bGFuZz0iRU4tQ0EiIHN0eWxlPSJmb250LXNpemU6MTEuMHB0Ij48bzpwPiZuYnNwOzwvbzpwPjwv
c3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBzdHlsZT0iY29sb3I6YmxhY2si
PlBsZWFzZSBsb2cgYW55IGlzc3VlcyBmb3VuZCBpbiB0aGUmbmJzcDs8L3NwYW4+PGEgaHJlZj0i
aHR0cHM6Ly9qaXJhLndoYW1jbG91ZC5jb20vIj48c3BhbiBzdHlsZT0iY29sb3I6cHVycGxlIj5p
c3N1ZSB0cmFja2luZyBzeXN0ZW08L3NwYW4+PC9hPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+
Ljwvc3Bhbj48c3BhbiBsYW5nPSJFTi1DQSIgc3R5bGU9ImNvbG9yOmJsYWNrIj48bzpwPjwvbzpw
Pjwvc3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIiBzdHlsZT0iY2FyZXQtY29sb3I6IHJn
YigwLCAwLCAwKTtmb250LXZhcmlhbnQtY2Fwczogbm9ybWFsO29ycGhhbnM6IGF1dG87dGV4dC1h
bGlnbjpzdGFydDt3aWRvd3M6IGF1dG87LXdlYmtpdC10ZXh0LXNpemUtYWRqdXN0OiBhdXRvOy13
ZWJraXQtdGV4dC1zdHJva2Utd2lkdGg6IDBweDt3b3JkLXNwYWNpbmc6MHB4Ij4NCjxzcGFuIHN0
eWxlPSJjb2xvcjpibGFjayI+Jm5ic3A7PC9zcGFuPjxzcGFuIGxhbmc9IkVOLUNBIiBzdHlsZT0i
Y29sb3I6YmxhY2siPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwi
IHN0eWxlPSJjYXJldC1jb2xvcjogcmdiKDAsIDAsIDApO2ZvbnQtdmFyaWFudC1jYXBzOiBub3Jt
YWw7b3JwaGFuczogYXV0bzt0ZXh0LWFsaWduOnN0YXJ0O3dpZG93czogYXV0bzstd2Via2l0LXRl
eHQtc2l6ZS1hZGp1c3Q6IGF1dG87LXdlYmtpdC10ZXh0LXN0cm9rZS13aWR0aDogMHB4O3dvcmQt
c3BhY2luZzowcHgiPg0KPHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj5UaGFua3MgdG8gYWxsIHRo
b3NlIHdobyBoYXZlIGNvbnRyaWJ1dGVkIHRvIHRoZSBjcmVhdGlvbiBvZiB0aGlzIHJlbGVhc2Uu
PC9zcGFuPjxzcGFuIGxhbmc9IkVOLUNBIiBzdHlsZT0iY29sb3I6YmxhY2siPjxvOnA+PC9vOnA+
PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiIHN0eWxlPSJjYXJldC1jb2xvcjogcmdi
KDAsIDAsIDApO2ZvbnQtdmFyaWFudC1jYXBzOiBub3JtYWw7b3JwaGFuczogYXV0bzt0ZXh0LWFs
aWduOnN0YXJ0O3dpZG93czogYXV0bzstd2Via2l0LXRleHQtc2l6ZS1hZGp1c3Q6IGF1dG87LXdl
YmtpdC10ZXh0LXN0cm9rZS13aWR0aDogMHB4O3dvcmQtc3BhY2luZzowcHgiPg0KPHNwYW4gc3R5
bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PHNwYW4gbGFuZz0iRU4tQ0EiIHN0eWxlPSJj
b2xvcjpibGFjayI+PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCIg
c3R5bGU9ImNhcmV0LWNvbG9yOiByZ2IoMCwgMCwgMCk7Zm9udC12YXJpYW50LWNhcHM6IG5vcm1h
bDtvcnBoYW5zOiBhdXRvO3RleHQtYWxpZ246c3RhcnQ7d2lkb3dzOiBhdXRvOy13ZWJraXQtdGV4
dC1zaXplLWFkanVzdDogYXV0bzstd2Via2l0LXRleHQtc3Ryb2tlLXdpZHRoOiAwcHg7d29yZC1z
cGFjaW5nOjBweCI+DQo8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPlRoZSBuZXh0IExUUyByZWxl
YXNlIHdpbGwgYmUgMi4xNS48L3NwYW4+ODxzcGFuIGxhbmc9IkVOLUNBIj48bzpwPjwvbzpwPjwv
c3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1DQSI+PG86cD4m
bmJzcDs8L286cD48L3NwYW4+PC9wPg0KPC9kaXY+DQo8L2JvZHk+DQo8L2h0bWw+DQo=

--_000_AF46A74316124659A12AE493EF4DF537whamcloudcom_--

--===============4378211364115739603==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4378211364115739603==--
