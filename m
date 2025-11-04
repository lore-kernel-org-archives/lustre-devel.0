Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5B528CCFA04
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 23:58:58 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1Q094GQrz20jr;
	Tue, 04 Nov 2025 15:39:21 -0800 (PST)
Received: from iad-out-012.esa.us-east-1.outbound.mail-perimeter.amazon.com
 (iad-out-012.esa.us-east-1.outbound.mail-perimeter.amazon.com [34.197.10.50])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1Pzj0Rvqz20fy
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 15:38:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazoncorp2;
 t=1762299537; x=1793835537;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=1omdR2ztdhlI1V6NG6uWUxdY4xoMC5JG5IAC2Zyj4b0=;
 b=myW/Tqrvv2wQEY77CgqvqMfjd8Q2k1R6IoEZcI7xwBKi6sYqYKSh4PzT
 ymS+94H6vE1usGC/PrmAXR2X3NysUkpVXHp5bIXMr5+YaBKFG8Zquxtx3
 CF2iscJ2eqKLBcOsZvAB1O9YeRmbs+M6FAiC9szy+2uNR+cAaB+xMQGDl
 MmDTkoxBdmuN5SQqQQLLCi0aY3BLMubYylGiJOGpqiFBFbYmvLKpmHlaf
 Sfx482JfqBHCmyLzDM06PKgVwpSb3sA8U3zEc1e//vwgfUaQHQwrlGPxv
 KRKSrT7ETcOhKvoeuwkmgkbE9cljIfQuV73I0oVj/IBs+xzwtcOTC2GE3 Q==;
X-CSE-ConnectionGUID: 2WhM5+sxRYONNWJvCv07vg==
X-CSE-MsgGUID: TxrO1QkXR6Ohqh0JubKTvw==
X-IronPort-AV: E=Sophos;i="6.19,280,1754956800"; 
   d="scan'208";a="5487900"
Thread-Topic: [lustre-devel] RFC: Spill device for Lustre OSD
Received: from ip-10-4-22-235.ec2.internal (HELO
 smtpout.naws.us-east-1.prod.farcaster.email.amazon.dev) ([10.4.22.235])
 by internal-iad-out-012.esa.us-east-1.outbound.mail-perimeter.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 Nov 2025 23:37:35 +0000
Received: from EX19MTAUEC002.ant.amazon.com [52.94.133.130:31009]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.54.238:2525]
 with esmtp (Farcaster)
 id 91e189e9-77fb-48d6-8237-64ff4ae101e4; Tue, 4 Nov 2025 23:37:34 +0000 (UTC)
X-Farcaster-Flow-ID: 91e189e9-77fb-48d6-8237-64ff4ae101e4
Received: from EX19EXOUEC002.ant.amazon.com (10.252.135.179) by
 EX19MTAUEC002.ant.amazon.com (10.252.135.253) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29;
 Tue, 4 Nov 2025 23:37:34 +0000
Received: from SN1PR07CU001.outbound.protection.outlook.com (10.252.135.199)
 by EX19EXOUEC002.ant.amazon.com (10.252.135.179) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29
 via Frontend Transport; Tue, 4 Nov 2025 23:37:34 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=qfqU1HhFiit36N5WVPGQwqhC2DCOitrfKTRge87fLT3DqU0aRSBIML58irFptOLogKBWPZVYm6FSIhvnzfRcOYJYDIOEbmOeke5ADUkSHxeQmCeTl8vCaerQ2XvaH3hL7PVlxnbJ+jfBnpB+HQN1O0x9Cuxb0rZcDr/EA+0m9HmELhpkVKdEGuxYmtKcScGNgIzjDlPwj/xpQPDBI/KAZhGjCeE68Ti6uIPXkGwx4crxs58oI+TnZvW5t3rCoUOHZIRApdvzrbYWNmtwQ12xD91lB97bhiUOMDd3KPU6JILj9j7uaEMJWnFN/sN7vpSFQE6ql/rTQqw4/J1yQwMOVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=1omdR2ztdhlI1V6NG6uWUxdY4xoMC5JG5IAC2Zyj4b0=;
 b=A4GNkwfng4qBXnJEp43vUpWvuqYzL1M5Zqo0codl/t5tVmfHHSvq/tEPCryDT1dfwVzLW6OaciNrUHVLDnWu6ZIuMCzHKW0Qq6SoRIY/PstX43eVafcztx36qAYARMl4XJhHiDMK/EP0awPYk6kOKGrC9QgzfyACWZjGZbsk7/0rleonKOqxOv8/5A5NC3Eq5obKMYiuu1aZ/QqWuNvaWhH1MmRf2ceM7gOQ4dgkbA6D3pia2XKN7Z5KOogvoKiyOF7UTkH3+VcOQ6DmnHCTfgbvR1mCK7G4NJmCGag/0mwgM2Ei96XFrGamvKrkLPKPKBR0BLCpminHXmKqdUDetQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=amazon.com; dmarc=pass action=none header.from=amazon.com;
 dkim=pass header.d=amazon.com; arc=none
Received: from DM6PR18MB3667.namprd18.prod.outlook.com (2603:10b6:5:2ae::22)
 by PH8PR18MB5357.namprd18.prod.outlook.com (2603:10b6:510:251::20) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9275.15; Tue, 4 Nov
 2025 23:37:32 +0000
Received: from DM6PR18MB3667.namprd18.prod.outlook.com
 ([fe80::2aeb:6b41:4331:4be1]) by DM6PR18MB3667.namprd18.prod.outlook.com
 ([fe80::2aeb:6b41:4331:4be1%4]) with mapi id 15.20.9275.015; Tue, 4 Nov 2025
 23:37:32 +0000
To: Oleg Drokin <green@whamcloud.com>, Andreas Dilger <adilger@ddn.com>
CC: Andreas Dilger <adilger@whamcloud.com>, "lustre-devel@lists.lustre.org"
 <lustre-devel@lists.lustre.org>
Thread-Index: AQHcTeEJjhIJnPL18kOCRCr5aDJJRbTi2GcA
Date: Tue, 4 Nov 2025 23:37:32 +0000
Message-ID: <FD4A7B76-719E-4537-9304-4D59F4E55489@amazon.com>
References: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
 <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
 <D8E0F0C0-1A5F-413A-82EA-F3CFA473D2E1@amazon.com>
 <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
 <437b0b502c6f00cc728b2b4d0decfc44ae7ecc52.camel@whamcloud.com>
In-Reply-To: <437b0b502c6f00cc728b2b4d0decfc44ae7ecc52.camel@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SetDate=2025-11-04T23:29:24Z;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ContentBits=0;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Tag=50, 3, 0,
 1; MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Name=Confidential;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ActionId=fb7faea5-e0cc-42a1-b051-96d0c29d0681;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SiteId=5280104a-472d-4538-9ccf-1e1d0efe8b1b;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Method=Standard; 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=amazon.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM6PR18MB3667:EE_|PH8PR18MB5357:EE_
x-ms-office365-filtering-correlation-id: a4da00ce-08c6-41b4-5dae-08de1bfb2040
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|1800799024|376014|366016|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?NzJTT2oyMFMvbm80RDhYL24wWlJ2NGo1Wko5NU5PWnVrOGZsRm0rL1RldWVU?=
 =?utf-8?B?OFlMN1hmWGJlRVNyd0R1ekIvQ3lKNE16YldCTGZUYTA5a1cvVTV1OEN1SlFi?=
 =?utf-8?B?S05jdEg2dm1MRVBHVGswZmoxYUl6WUtlRzJESEJJZVhPR3VyU0xxVkdzeW11?=
 =?utf-8?B?U0kvNS9UUzdLbGF1dTBUUE9ZYzI4bFhWMktzZzB2NjV3aU0zaTNXS29XbnVZ?=
 =?utf-8?B?RDlhSXJLNkNjZS9DWTRQVXRvK1VpVjg5cTQyRllYeGxJejU2b1l3dk5sSngr?=
 =?utf-8?B?RXVyWXBieGR5ZUJOaGtHaWVwZmEwaGJjNDZWUFhUMmdJVlpKMWpQOWpSeDNs?=
 =?utf-8?B?dzM1MDVuNlk1RzllaUVEeURoQ2QzaUpLenBHK2wzb0NGU0VGU2xPeFJoVWJt?=
 =?utf-8?B?eUt4SWEwVUtFUkFlZG5acThUVVk3UENFUkRtZU1xUG5NMkJIWkI5b3o5cGRT?=
 =?utf-8?B?RDlqL3g4TklTTm5EQUl1SmljUkxySVMyc3Z5bzRtM0tBZER1VFZKREhBUFdy?=
 =?utf-8?B?ajhQQ0JLTTh5dFZ4OXhIL09YVXBZVnVkMFFBd2l3SENEcmxhek1GRExGOHBW?=
 =?utf-8?B?UUVKQWZLdlRLaVdMaVFwK0FDazZIdlNLc2gwNmdROUpEZ2c4UTRNSEN4WU9z?=
 =?utf-8?B?aVh4TExXL1lDdWJXWEpNeDFiQko0WHV1RkE3bUpMVzVmRStIS1RDem1mWHRj?=
 =?utf-8?B?QzRRTnRKQ0VaWmsrSmFaZzR5dHhiR2NhOENzOTM1OFZtT0RpdUxhVnN2NG9L?=
 =?utf-8?B?M1BIeU9sTjBpTi9IdDB4ZFRBdnk4MWFNZlBZVWZFbmdCdE13MXg4OTBwS1gz?=
 =?utf-8?B?K3lTdW14bGpKR0p6REZ3cEt4VVkrZndBamNueWZxVTF0aEQ1cWROb2lFVCsv?=
 =?utf-8?B?ck5DMWlHbDQ2MFIxdXh3WXM3TGdWbDFvVE1zZndtcHRDeGswb25RVkRhS20x?=
 =?utf-8?B?VHhzdUczMVZTVk05dDJxRzdIVk9MbkZBcC9pbDNBWHQ5eEthUUxQWUlDaG9l?=
 =?utf-8?B?VllNVnpVTW1TeUVDMjA2dGhOZTg3ZVdvWncwamtzUnFmRVhvRnhJMkpPQUNE?=
 =?utf-8?B?aTdwY1RwNVJ3S2xZQWNEaWxGVnFSNzVwN0xsRkVyMGpUcjNpVVFHV25CL3V1?=
 =?utf-8?B?Z1FEdC9LYWZOVXptNEJvaW1McE5zS1lMaWZ0akpwZmVFM2wxZWR3SFl0d1Ju?=
 =?utf-8?B?WGw3eTc2SDVjRG0raG54Z3JCbHU1cysvcFhmdFlzdTlqUVp6cjMyT3J6S0N6?=
 =?utf-8?B?b1J4OGhKVUZyOWdPTkt1WVhlV3JBTXcyVGdjSk5KWnh1eDA0alNyWSt1OXNZ?=
 =?utf-8?B?NWphQVFqUnlEUW80c0JxemdZMGtSdkoxQ0swbVd6SHBseEEyYWI2R3lqSzNk?=
 =?utf-8?B?ZnBSR2N1UHJKNmxTMjM0MFNjcVhWQjBWYmZMSUl0and5SExNSDd1TnptSVRI?=
 =?utf-8?B?b0R6ckVqU25vS0NHekFoMjhuNmRkZGpMSFBtT3hHRjZrd2MvUWR1emxCRjZ4?=
 =?utf-8?B?Uk1kSGlGRjdEbS9UaGFvZU9iUi9XNnRLaS9GcWtYWXIvS3NucGRZdjMyRTI1?=
 =?utf-8?B?WlZ3Y3dRNVpEdlRTeHZreFdRVW9IWTlPeHp1RlNDclg1azAyL2RPOUsvNHhz?=
 =?utf-8?B?dmZrQlFlZjZsSnJSUXpqOVZzOHNEOHc4SjRaS05tdlFLVlNxMnBnMkZwZmY3?=
 =?utf-8?B?cDdHakRSZ1h3STFIR09WdGhhN3dRbmtQYkcyWkJUOERNRFJzT1hZUGlWdWtj?=
 =?utf-8?B?RzBaMVl2a1RmYmRVZjJrU0FFSnpRUUZqbk4xdDhzQXUxbGdMR3NUY3R4VXo5?=
 =?utf-8?B?VlliM1R1VkcxaG9RMnhJQ0IvcEpkUEtvbThxWTZvbWNLams3a2RyUUlvZFBX?=
 =?utf-8?B?NmhibXBWa0NFZGFmL1ZiTUNQMjZ6enpWT3Y2Wm11c2hMVkorbGI4dXEvcGM1?=
 =?utf-8?B?UnBRNmRaS2I3OTBqcnU5QmdTOEwyQjFPRzFtRk9FdmNVWHBnMVVFNHYrTGt1?=
 =?utf-8?B?ckhFTGVKTE5UNEo4MFlaWm5jQjFaU0hWTUE3NHhabzJXVUh0c3l0Slg0ajhZ?=
 =?utf-8?Q?bCYU3g?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM6PR18MB3667.namprd18.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(376014)(366016)(38070700021); DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?NmQ4TVM5L0FsN1hHNTdTSXNDNkJZUGVTTHphNUN2UWFUVHhua0NqL0NUTjdW?=
 =?utf-8?B?TGRZeG9paW5tc0RCdXRzMmQ0U1pUYmNrRWZkeHl1YjdsMVh3eEVkVllubEor?=
 =?utf-8?B?T2pkOFVDaDZra1JicU1Tdjg3Z2dEd1hSWGRZa05qeFJRZnVVUHdxY3k1QmVz?=
 =?utf-8?B?OEg4Z0RrWDZBQW9jNk5SbkR1Ti9jMkVvMENxTTNaT2tESy83Y2R5NU9wNkpD?=
 =?utf-8?B?Q3Z1eEs5RDJGcUNVZG5KNWlCVjF0aFdFSFAyb3hwcXovTmJKMTNOM0tmZ2tC?=
 =?utf-8?B?dEg3bGJQZ0VSUk0wU21zRGZIR0V5S2FZQ0t5QWNvQ2pudElCWDZkMk9Gc3JI?=
 =?utf-8?B?VXhkZzZnVXVnK1RBM3RvWTIwVUpPSW5HekpWY2Yyc1FEcmdCU1VHZmc3bDlz?=
 =?utf-8?B?QTVLd2ppVjRoM0Jxb1N3cGxLMUx6RVZ3NmRaR3VLT1VRS25WZVRlVUljTGRr?=
 =?utf-8?B?dC9NeGVRd3JqY0I2MUJOdUFrRzFyTWNBMVMxZDlUcmNaenBRMldIWFpsbjRQ?=
 =?utf-8?B?OHNNWVJtUlZhODh5ekVrZ1d1OFk0anlOcnNPeVdCeHd0WkhGcEpEVHcxSjlO?=
 =?utf-8?B?UFFlTGhDY3c0WlRIQ3JqZnFJUHc2WHU2cDdwQ3ZjVEplMW0rVXUzWXB2cEdq?=
 =?utf-8?B?d0QyVzFVQ0tDd0xxdUNXaTFjSnF3RjM1RmEwdVJ5cFhRQ3ZialhWamMxVHhZ?=
 =?utf-8?B?cGJVd2JJdktLYUVqK2xiQy9QbndZaERYQkI3dmJONFozVEpqZ3U0ekJWU25y?=
 =?utf-8?B?M0Z0L20wT1g1Q0dMN29hM3RjNEJ1WEpPenBEZFd4TU03aXRTS1phTmtsUGpl?=
 =?utf-8?B?NzZ1RTlVZGZ1aFRGWjFCNDd6bWtwYjhpTG5sYjY3L2J6M1phbEVwM3hrYmhT?=
 =?utf-8?B?MG1iWlNNNnEzN0Y1ckx1Y0FwdlE1NTg3VkxhWHdSVEgwTlljRGxBeDVUUGhC?=
 =?utf-8?B?MVZ5Szh5b3REcisrTW13eWovaUd2OXNNNU5HZnlUc2RqSU1LeHpKcXZNRksz?=
 =?utf-8?B?SU93bEdUZ0RhbXFCUlNrd09kRngyZ2xST0xRKzJDYlBPZUJ1WjZ1WVZpT1ZU?=
 =?utf-8?B?NDJhYWpTWnFwNHV2TlBybmNqdHdYUkFvSThsMkxrNVNYNmhUT2xodmVjMXUw?=
 =?utf-8?B?NzlYRGxlUUQxMnp3QitGRzlabkI1Nkg0d3R3MWNLUVJUTllNdDRla0RRTTYy?=
 =?utf-8?B?akJFdGhiaDRFUlUzaUFuUHFmQVlOeG5SQ0dBNlgvQkVLOURrUFJDTGFZbmlv?=
 =?utf-8?B?NFdxb2pNc0FJTmRTTjI0T0hjUm5zYndNZHZ4TkwyR01DNldhY2RleDZOck4r?=
 =?utf-8?B?bGpXQTJUY2JSZ2RQZzVNend5MVZxUnVvSHBSMW9xcHpIVzhId01pVWhXczdN?=
 =?utf-8?B?N1UwVlc0OVFBQzNtQUFFMy8zRUhBUGhSRVM2WW45MkdRMHhKVjYxS0ExeEVZ?=
 =?utf-8?B?Z040cVZKbXZvKzdKZzlsdUlodUxsN1FHUEY4empWU1BVUXptMU9TQ3RGK0xt?=
 =?utf-8?B?NnlYSytURE1ibW5tb0pKenE2dDdBUTZnZkNTTXRVYlp2a0g4STdKT2QyOTho?=
 =?utf-8?B?WXRqQ0hHeHN2eVg3SW5Ndm1HN3B4RG1xSnhNWEFDcGYyWlVnK1RPeDdGek9U?=
 =?utf-8?B?VGtZdE80TGR1bXcwRkQ2eGdRemZaK0pjVGt2MWpGVCs2SU9GaDBjTVN6MVE3?=
 =?utf-8?B?V2NvekFYOFQzZEY0M013dWp1WG5IQ1paSDVCU254eWJuRjIvaCtudXpHWFdu?=
 =?utf-8?B?NU1vVmQ4MC94Z3BiYWR2OEhMQ3BqY2p0UVI3ZGJlb0VMN0l1RkowNlR5RVpR?=
 =?utf-8?B?YjdnYjZOMWd6d0NCYmZFb2xZSU5DVFkzUmZ4aW5sZWFMVWNVYmkrRXZSRDV4?=
 =?utf-8?B?WnFpUXlWWGdDQzNVZGViMVg2TGQvamtWWkVsUHp1OVBFcW1CTVZRcW4ySDdQ?=
 =?utf-8?B?SE9aaTlvUW12by9qMVZSYjdFUFNxc042NWtQNmliUXQ0c3lpSEwwT0FVNVc3?=
 =?utf-8?B?ODNyWWNmMHBlb1JobHVOa1NBaDNLRWR4OFBCcGl3dVdHYkNxZ3dxREFVb3Fu?=
 =?utf-8?B?YkFyQUJ3MUJaWTFHZ2oxbHJ3bWdjZzEzM0NlRlBmbDZ5Ry8yMFd4V3UwV3p1?=
 =?utf-8?Q?koIBsDekFcdoO90uafW48Ad2l?=
Content-ID: <B2AE2615BF7F2C49AFE7B9A36545C0C9@namprd18.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM6PR18MB3667.namprd18.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a4da00ce-08c6-41b4-5dae-08de1bfb2040
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Nov 2025 23:37:32.4815 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5280104a-472d-4538-9ccf-1e1d0efe8b1b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: /F+uFlgYvgAH4veYk2uWKGTZ+QeaXohfxFKbJrQlbyie7vRs0zQaGE4tLNGRJ4soJmNXAeMdznl2YCgUo6i/5w==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH8PR18MB5357
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

>> If we can implement a no-transaction osd-vfs, that would expose a
>> lot of flexibility for other reasons as well. Possibly the osd-vfs
>> could
>> implement a journal or other logging layer internally to make up for
>> lack of transactions, whether initially or at a later stage?
>
>That's actually an interesting idea, but probably not very practical.
>The journal itself is probably not really feasible with VFS api alone
>because you need to touch journal together with whatever it you are
>modifying, unless you update the journal first and then everything
>else, but that is likely going to be slow due to all the overhead?
>That's probably why all the journaling filesystems hide the journal
>inside themselves out of reach for the VFS api.
>Of course VFS api could probably be extended eventually if there's a
>good justification, but who knows how long it'll take and how the final
>agreed upon implementation would actually look like.

Databases do this kind of journaling and they use normal filesystem
APIs. And they can do this with a similar performance profile as a
Lustre OSS or MDS. OSD is pretty much a database on top of a normal
filesystem. So I think it's possible.

If we had a no-atomic-transaction osd-vfs, we could perhaps use it
for stand-alone MGS. Before ending each write transaction, the osd-vfs
could fsync() the whole filesystem. This isn't feasible for MDS or OSS, of
course. But performance demands on MGS are low enough (I suspect)
that this would work.

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
