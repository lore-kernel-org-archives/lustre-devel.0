Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9BAA7C02192
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Feb 2025 12:05:23 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YnzSz0JSxz1xcc;
	Wed, 05 Feb 2025 04:05:23 -0800 (PST)
Received: from outbound-ip191b.ess.barracuda.com
 (outbound-ip191b.ess.barracuda.com [209.222.82.124])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YnzSt48Tkz1x4m
 for <lustre-devel@lists.lustre.org>; Wed, 05 Feb 2025 04:05:18 -0800 (PST)
Received: from NAM11-CO1-obe.outbound.protection.outlook.com
 (mail-co1nam11lp2170.outbound.protection.outlook.com [104.47.56.170]) by
 mx-outbound40-249.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Wed, 05 Feb 2025 12:05:14 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=q5/Tmmu+/QsK4K8ntJHNHX1tR1u0oV4jDnP3gDQvEtPdE01Kaltxh0SpOGSgNkSBqtcD3uaU4mBUQGTkn0V0IYbIcTG3qlxvqU8M6V/IblbVmXarDwti/ewnJ/N6VrSQ692lcttNcMQPWhuIJm2n7ZliOKxhQMpa+rn6u9PpdwwX4iGrlGpwwmwubUKlOKGf6fdxhoQB4zs2s+aJIStsN1I9GNLa3l1m1F99p6udKZMDsso4e/pWEj/MVVNrbHVcW5O5M57rQv5slUNbQq5sPfRcu8Xk0ukYSsyvRqGEgdRoiCUbffNN7HOCJG7psx+mOaVFPTMHlM4Xr3oAaXa4xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=KPXQg3hHGjLcCAueqWJ/0za8HXzySa17tmNX3Yy7Zg4=;
 b=wNSXIz/H4vPl2hUtfsBxfO8+ZLSjS8/vKyQSnEnxye21gbHnAkjgv7n+1gguBDRYOguEOIDO1Fov/YsyPg5mKjCoUkD6uq6K1ut6yHWRTBQKiAhnmUtpHjtCkkKiAW4W81S2EnMOR1Jj5BE5vt0XQQJtjzTatx9CpjNQkxHk2HGMFB97nxnS5nWvnXdQtBMSdPRbtmqFzIdKKfr/OnyUYaJ4qD/mAa441lMY2k1oWn1iFU7BVeVlIkQfqcMZp9cjXhP8r1+DGix7TBKwpsv3x8LmRi/4j+ryh3QbYWzUUjGbDz4mY/3gPRr7dSnix/mZl24Tl1uOdLgz5a633T/+GA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=KPXQg3hHGjLcCAueqWJ/0za8HXzySa17tmNX3Yy7Zg4=;
 b=C4qK1hLJ3W5j26b1y49sapdBLy6C70NMwnIVj09EDWfM2n5EuR220+gkUgWzNM7SgobLj+5MLvS3c0uSB+PRA3KmwbwEz4O5kCGsIq33d1xjBEpuWjungh8W/Ovm9OfRZEqq+8AsEDolv6gvFhpsLZlVNnWi+yuLrIZ8z07uGg0=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by MN2PR19MB3789.namprd19.prod.outlook.com (2603:10b6:208:19e::24)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8398.24; Wed, 5 Feb
 2025 12:05:12 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2%6]) with mapi id 15.20.8398.025; Wed, 5 Feb 2025
 12:05:11 +0000
From: Andreas Dilger <adilger@ddn.com>
To: Oleg Drokin <green@whamcloud.com>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAAUdfgIABebkAgAf62QCAAH1kAIAMBm2AgAASkoCAAr/pAIAAJnkAgAAH54CAAAPkgIAAAWoAgADH0wCAAKtNgIAAOLaA
Date: Wed, 5 Feb 2025 12:05:11 +0000
Message-ID: <3B83582B-2D34-4D54-97AF-67E36E93FF74@ddn.com>
References: <4243d258f1a38e8539e88a68fb705f05bf18dfb1.camel@whamcloud.com>
In-Reply-To: <4243d258f1a38e8539e88a68fb705f05bf18dfb1.camel@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|MN2PR19MB3789:EE_
x-ms-office365-filtering-correlation-id: 684da87f-e7fa-4188-8e2b-08dd45dd57ac
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|1800799024|376014|366016|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?cTNqOWo3Y0FrclFVTTF0b0UvRXBGRUJhcVd0SGV2UXpjbFJIaVVOQ2E2Mi8y?=
 =?utf-8?B?Sk9udWJXUkttTjEzY2VwVmE3dmFKQzZabVd2WVVDVUcycnpscFplMTgxeENq?=
 =?utf-8?B?OGdZeDVMUEI3Q0E0M2dBbkN3WktHL3ZRbHcxWFlVdDU1NzRvTkswQ0xIZXRv?=
 =?utf-8?B?Sk9qM2VpMStoN0lVVHYwS2t3T2MyODFmb0xpL1hBNTJHbFM2aFllQUp1Zkl6?=
 =?utf-8?B?bHFsbyt6YzRNanY0V24zOTNoQjN5UEgyMWVoYzhvaTRTbWh3TllrYU9nbG91?=
 =?utf-8?B?VkdSNDk1VXRuNXRKVXZMWUJURjFUQ29kaGlFYk5sVFdNWHdQeHRQSkxNSDJZ?=
 =?utf-8?B?cmowWjI2c1FKNDEybkhOdU1kL0xsN2lGamVxcWx3akJmODJJNS9IM1NJVFZi?=
 =?utf-8?B?VVV6UisxTlRFeUZXL0I2MWZmb3FBWHBQVVF6VU43aFZCT0xkMWthdEZ4WXMv?=
 =?utf-8?B?MnNFdlArUnVVM3dlK0pHbm9YSHdCTGMxUmsrM1oraDNUVkpMRk5WUGtJUzlM?=
 =?utf-8?B?YWtxNUdCTXdOZjVjL0x4WVdnckE1czZxU0R6dXY5VlNVUUNlV1hiN1NET2FT?=
 =?utf-8?B?OGtYeTkvMnAwRjNCQXdjSnR5NjFGYmFQbmVKNFJhYnRLdnhBSGlVQVVqWnVZ?=
 =?utf-8?B?WEpHcjBtd1M1NHY4eTU4Y3pNNlhieG1vRzlFUzFFU1p2ZkVQbWZaUkM4Wjgw?=
 =?utf-8?B?ODZ0VldHZWhCS1V4TUZFbytheUNzYmJwaW1DdzhWaCtGTy9kTUtMTy84dGgr?=
 =?utf-8?B?dEVTYjdXR2xQYTVtZ2tWbS8xODJNSlM5azEyOHVNRE8rSkdNRHVLRnlldzZl?=
 =?utf-8?B?aXFiYWxqUzY2RUFTS3RZRC9lQmVsbXNLUlp3aE5EU1VLTk9nbHRRelNWelRw?=
 =?utf-8?B?NXRUejExVXhwWHp5OXFTZXhrUldkbm52Ly9NbUQ1QUVVN3Mvd1ptWXl3d01W?=
 =?utf-8?B?ZEtFMjAzby9SMitaRk9nSytOOWxGa3QwN0tVcVNMaUtHcFovMmFkQktUZ1Ns?=
 =?utf-8?B?WklCcU5xNjZoZjRpOWh5M0N1WUkwU3B5QkgwUFRBYitOOWhSVHBlYVdQQzhi?=
 =?utf-8?B?YjY4ejRic1FiZXJ6OUExbnRXRGowNHM0NnNhV25kYVJQdXQ2RTFkMzBpcWVK?=
 =?utf-8?B?S0dyRTArNWpUUzNFWUhpcXV5dmxZM1R5TmxJRkNHSkJZdGdrV1Q2Y09kd3Jm?=
 =?utf-8?B?azR4QXNHaEM5b0VVajZzYkpCYTB6Uk5tNG13a0ZaT0hoR1l2U1orSWc2bytU?=
 =?utf-8?B?QzlXTVVyQzNBTURmdzY1dU9hZml5NnZ3WlRMSDBTbk9nVGNRZllEd0RLenJT?=
 =?utf-8?B?Z2lGb1diN1ljZUhoOVFRb3JBZkdEeGZQSHJhQVZ2c256a3UxcnIrMGlLZ1BQ?=
 =?utf-8?B?TEFEVjU5MGRROWNJRncwY2RPMTdZbUkvR3o1SC9xeDFtU1BpWTJyVEdhRFBi?=
 =?utf-8?B?c2hFVzdiNHNsaHEyaS9XaG5laUJzbCtJVit0ZjFOcTBqNEdIM2RBOFNFV3lP?=
 =?utf-8?B?dTdQdDJKNWtnTzRjTjJUbDc5N2ZMQ3FuTG1LTTlzWkNGSVhJV1BrRW5PYkN6?=
 =?utf-8?B?S3NiV3gzZURGSnA5ZUtaQnM1U2c0R25CRnZqY1V6dGVRYzdLWUNlcFF5TDdE?=
 =?utf-8?B?SHdMUzZFczNybjF5UFZXcXZZZUFodTZXZkgyNk03Z3JIYUFIU3ZrVko5SEZ5?=
 =?utf-8?B?cE5ab0xBMVpXY0xCdEo3c2hySXFwaDBBOTlYSXp0Y1pEWU5kMzRnNWxiUnFv?=
 =?utf-8?B?NTJYajJicU5yNmZkWWN1LzRHd1dlSUszczZiSTRNdGU3TGdRNDkrQlZoWjhC?=
 =?utf-8?B?TzRQRzJINVA1eXdEQTMvRXBIQ2NXczNEUnE0ZTZvbFUzdnk1OVZHb0oxYWNp?=
 =?utf-8?B?ZmpnM054bVpxNmltTU90ZS9PMFczVm5lMENOZ0V3aUxZakE9PQ==?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(376014)(366016)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?WjcxelBVQmFZN0RpZWJ6bUdQQjFhcC9ma1IyL3o3NG9CcGRaZzBMVXQzVWRz?=
 =?utf-8?B?a1hlYy9wYlNadlpkNS9TbUFSQW5aNlczdFNyNlhkMDNEVEpRZjB1YXNTNGhx?=
 =?utf-8?B?OUlaMWxoRGJOL0U0ZUtPNEl1VzZtR2VCaFRQVkZnSSt2NnRzelpCa0I2L2gr?=
 =?utf-8?B?TlhzQVovaTBlR3lQZFNZcE9jTTBxc1FBRXZ1MHQ2dURTek55RWs4TVF2bVQ4?=
 =?utf-8?B?TndsSmNyOU5sdmlsOHA3Nk5MdCsxZWxkV3BVUDBKVWpBZVEwNzhEZEtRN245?=
 =?utf-8?B?Q0dnRlQyMFFTRCtWbzc5cTg3a1d5djNPdmJQMGhSMTB5dGJXOVF6WTN4eVh6?=
 =?utf-8?B?WU82dm9CWm44bG00Sjhlb1hMT2QwSldXSmJoYm5oTkNYbE9HZ2RTWnJCa050?=
 =?utf-8?B?emZxSzJQTHBDaWJOZExEZC9aeU1leC8xNXByZFNKaUp1Kys4b0ZWZEs3dnNM?=
 =?utf-8?B?S2FyRTFXZlNidW5MSFhaZUFSbFY2MjZDalU4ZFYyUXFTN3FmamtYYkk5eHNX?=
 =?utf-8?B?Rlk4MFJMZVZBNUFLSVIzaG1vOEdXWGo4U1ByTTZ2QWhIcUxPN3pwamhDczhN?=
 =?utf-8?B?U2NoZjdleFYxU3psczdOMnFvamNVRkh0UzkyOWYyOHFjMlBYWGNGZmI4WDBu?=
 =?utf-8?B?ZXR1cEpLN1A0MlZhSzRyZWM2OGhRdm1lV3FvWDZjaTdlRWRGOUNsRlkvYkdB?=
 =?utf-8?B?N1g2TldFZ1U2YndQbDhTQlJydjZONlhDdTN1U2JPdlM5Y1JuVDNTQWJBN2s4?=
 =?utf-8?B?K1haY2NkdVRoUVVrRzd5UzBpaXcrVnlReE5CejZsRm5zSmdKWkFEMVFLUXhm?=
 =?utf-8?B?aUNpRFFtREtIUGJQeGZVWWJMSmk4U2p3bzVyMVZQUWdwTVpNdTZjV3lSc1pU?=
 =?utf-8?B?R1lpVkRablJlR3NuTkF3cGVyckdFblJHVTd0b2FSbm51RVlTOHkzS2RZM2RB?=
 =?utf-8?B?R3k2OVhqNU94Uk5JM2szZHRzQkI3K2NKMWJnVEtGRUhpY2JxU1NwS25IaUYx?=
 =?utf-8?B?MzFSck4vaHVyYlNwb0wrcG4rdUY2aHRUUCs5eFU0ay9Uai9iZmFsZ2pHZHdk?=
 =?utf-8?B?VjN4Z2Q0WjRtWW95L09SRnE0emZlMFgxaStZUnFDTjJSZFJMZUY0MDlXd2hM?=
 =?utf-8?B?dUJidjZhM1RjT0U3RTBra1cxOFNMc0VqNU1VL1RiS3lQelpQZ2FhNDRoMTEz?=
 =?utf-8?B?SzBZRUZHTkpvcm5CM2E0cEJLRGdIQXpVVGN3eUlEbStqbEQ1TEx2Q3loWXZF?=
 =?utf-8?B?T0FWMmYzNm1lQUZMZzQrVTl1SkJLSTNQRFlhZ24vYjJCNkh5SWNzMm5KRms2?=
 =?utf-8?B?c2JaemtSeDhvMWV2R1EyYWh1KzdqNUk5aTZid0JxMUY3QVk2QjdkYTZVUFVw?=
 =?utf-8?B?L0pXcTdGVTlBNjFsS0ZXbUdESnBRekdJeUtwcW9Ec2VEU2xzNGRJSm85N1BB?=
 =?utf-8?B?L3NqMWxORmdBaU5mTlliTUJ5OUt5dms1UytEclhlTkNOQmJVZXFFS1oyYSti?=
 =?utf-8?B?RmMzeGw4eXRjSHN3ZFA3cXI2c2Zxcjh1MnBiWUh2UVVrN0NteS9halM3MGNB?=
 =?utf-8?B?Z2puMUZkd0Z1bnlGOWIwbmlYSExmRVhzdm01WWhrL3dwdmFTZjl4YncrQWhj?=
 =?utf-8?B?aDdyUkw0NjlsdDkvd3ZoY2Yva1UzcjBjU05sTFdjaGhPaDFjL0V4UFJNOUw5?=
 =?utf-8?B?NmxlQU0wZXVDNWx5VjhNS21vVXJXM0tkNDNhMEl3cUZBeE5NVktib3hucGhw?=
 =?utf-8?B?ZmwxNzdiZnJqL3BvR3FEVktFblZRa25icnRQcnlvNEdMZU1zVTVnekhsZUhs?=
 =?utf-8?B?VUsva1g5UUJFdUJPNFdHSGY0Z3dRcitiQzJEZFZWQmF0ZE1yR1dPdU9SWnZ3?=
 =?utf-8?B?NUhsNnBXTDd3WlJFVXp5bStpYm9Lcyt4Y0lnZ29ad2hHdDdKc2V1a3JwZERN?=
 =?utf-8?B?NVAwUXBmY3FWTUcxOTkzWFhweUlNOG8rbTBibm51d3RlSHQ0VC9SNHVXcnk5?=
 =?utf-8?B?WWE4N2VhVFc1V2tCeE1VblRCYVVoT2dnMThvWVdndnhNQkpOU28yeEZNZFh0?=
 =?utf-8?B?ejJNZ0pUaWRuRTYyQjgzQ3Jja3RTNXZxUnptMzh3Y2FBaFZiellXMDgvaXly?=
 =?utf-8?Q?+9AwNi6m7mFW9d6G96E7dOJmw?=
Content-ID: <04BFC24936DBA742B26CCE10134BCD77@teamddn.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: WQndYyRY++aYoSqunn2mmGS2QqTCGP1VsAjBD0CnidzY6PaBhic1k6ZkN0xX9Julirhmy2eQQDFXcibtHYRGaaPw4Le8O+m30mT9CLq88cOmmOpuY/odNKVJ7CmIOtHwZR0MygqD/APSjjW4Smv68H9M87WYspCl2ci+CaBwbIWtW2oFsPATlB4xw/NrT85TBqqCfW49J4gicEfGe3cLlTfKje6PMVVISsGRmCzOlbVYqLNEG1z40LBRnkZaCIjj7McOn0TSWNC4Uas4hPrpj9OlN8CEsSaW0pkTDCHqKbMGobaADoAjPNhzkQoYSOlxL/+Et311nuFDXfD26gUctyyPmu4oAzrKm6hzj5aCa2olrgRw3JMUCq3hz4e6NY5IfTvZ4GHEt+bHYHgp3UIGUuitVDqTsA8s3VozFli4IMY0/yU28o/0695uUvfIOxQQdSQQm8opyqqGNUblf4fNiwBF9BQb5qlqddM4xi3J3S+vUVFg8Uok4knUOIRBVy+b4EUwl4pImnxtI+LVFHcXvGEBEJzPQ6VAmr+S0H5LGniuWCZdLUxRIl0kh8QzbWJGclADTIYB4EJuWJuQHvfXtvFNFWNhvRsOzgZnHb2tWefpLa1/vz/PBW0s+mc3wyMnpo5lmf+Cux7WrK/yHqFDPQ==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 684da87f-e7fa-4188-8e2b-08dd45dd57ac
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Feb 2025 12:05:11.7452 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: oxY1qV9pvf1hw32mIa6gHH7Zld2uUS1LwthWThi6KWcEn4243/W0mtk8JIrcsveN
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR19MB3789
X-BESS-ID: 1738757114-110489-7559-7903-1
X-BESS-VER: 2019.1_20250203.2302
X-BESS-Apparent-Source-IP: 104.47.56.170
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVkaWpmZAVgZQ0CglLcnQwNIiMT
 E5OTExzTzZxDw1xcLYwiLFKM0sLclYqTYWAFDb3pdBAAAA
X-BESS-Outbound-Spam-Score: 0.10
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.262304 [from 
 cloudscan21-162.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.10 BSF_SC0_SA085          META: Custom Rule SA085 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.10 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_SC0_SA085, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

VG8gYmV0dGVyIGNvdmVyIHRoZSBza2V3IGJldHdlZW4gZGlmZmVyZW50IFZNcyBydW5uaW5nIGRp
ZmZlcmVudCBzdWJ0ZXN0cywgd2UgY291bGQgY2hhbmdlIHRoZSB0ZXN0LWZyYW1ld29yayBjb2Rl
IHRvIHJ1biB0aGUgc3VidGVzdHMgaW4gZGlmZmVyZW50IG9yZGVyIChlaXRoZXIgc3RhcnRpbmcg
YXQgYSByYW5kb20gb2Zmc2V0LCBvciBpbiByYW5kb20gb3JkZXIpLg0KDQpUaGlzIHdvdWxkIGFs
c28gZXhwb3NlIHNvbWUgaGlkZGVuIGFzc3VtcHRpb25zIGFuZCBkZXBlbmRlbmNpZXMgaW4gdGhl
IHN1YnRlc3RzIHRoZW1zZWx2ZXMsIHNvIHRoYXQgd291bGQgbmVlZCB0byBiZSBmaXhlZCB0byBh
dm9pZCBmYWxzZSB0ZXN0IGZhaWx1cmVzLCBidXQgdGhlIG1haW4gZ29hbCBvZiB0aGUgYm9pbHBv
dCB0ZXN0aW5nIGlzIGZpbmRpbmcgY3Jhc2hlcy9kZWFkbG9ja3MsIHNvIGlmIGEgZmV3IHRlc3Rz
IGZhaWwgYmVjYXVzZSBvZiBtaW5vciB0ZXN0IGlzc3VlcyBJIGRvbid0IHRoaW5rIHRoYXQgaXMg
YSBibG9ja2VyLiANCg0KQ2hlZXJzLCBBbmRyZWFzDQoNCj4gT24gRmViIDQsIDIwMjUsIGF0IDEz
OjM4LCBPbGVnIERyb2tpbiA8Z3JlZW5Ad2hhbWNsb3VkLmNvbT4gd3JvdGU6DQo+IA0KPiDvu79P
biBUdWUsIDIwMjUtMDItMDQgYXQgMTc6MzMgKzAwMDAsIEFuZHJlYXMgRGlsZ2VyIHdyb3RlOg0K
Pj4gWW91IG92ZXJsb29rIHRoYXQgVGltIHdvcmtzIGZvciBBV1MsIHNvIGhlIHdvdWxkIG5vdCBh
Y3R1YWxseSBwYXkgdG8NCj4+IHJ1biB0aGVzZSBub2Rlcy4gSGUgY291bGQgcnVuIGluIG1hY2hp
bmUgaWRsZSB0aW1lcyB3aGlsZSBubyBleHRlcm5hbA0KPj4gY3VzdG9tZXIgaXMgcGF5aW5nIGZv
ciB0aGVtLg0KPiANCj4gSWYgdGhpcyBjb3VsZCBiZSBhcnJhbmdlZCB0aGF0IHdvdWxkIGJlIGdy
ZWF0IG9mIGNvdXJzZSwgYnV0IEkgZG9uJ3QNCj4gd2FudCB0byBhc3N1bWUgc29tZXRoaW5nIG9m
IHRoaXMgbmF0dXJlIHVubGVzcyBleHBsaWNpdGx5IHN0YXRlZC4gQW5kDQo+IHdobyBrbm93cyB3
aGF0IHNvcnQgb2YgaW50ZXJuYWwgYWNjb3VudGluZyB0aGVyZSBtaWdodCBiZSBpbiBwbGFjZSB0
bw0KPiBrZWVwIHRyYWNrIChhbmQgYXBwcm92ZSkgdXNlcyBsaWtlIHRoaXMgdG9vLg0KPiANCj4+
IEkgc3VzcGVjdCB3aXRoIHRoZSByYW5kb20gbmF0dXJlIG9mIHRoZSBib2lscG90IHRoYXQgaXQg
aXMgdGhlIHRvdGFsDQo+PiBudW1iZXIgb2YgaG91cnMgcnVudGltZSB0aGF0IG1hdHRlciwgbm90
IHdoZXRoZXIgdGhleSBhcmUgY29udGlndW91cw0KPj4gb3Igbm90LiAgU28gcnVubmluZyAyNHgg
Ym9pbHBvdCBub2RlcyBmb3IgMWggZHVyaW5nIG9mZi1wZWFrIHRpbWVzDQo+PiB3b3VsZCBsaWtl
bHkgcHJvZHVjZSB0aGUgc2FtZSByZXN1bHQgYXMgMjRoIGNvbnRpbnVvdXMgb24gb25lIG5vZGUu
DQo+IA0KPiBXZWxsLCBub3QgZXhhY3RseSB0cnVlLiBUaGVyZSBuZWVkIHRvIGJlIGNvbnRpbnVv
dXMgY2h1bmtzIG9mIGF0IGxlYXN0DQo+IDF4IHRoZSBsb25nZXN0IHRlc3RydW4gYW5kIHByZWZl
cmFibHkgbXVjaCBtb3JlICgyeCBpcyBiZXR0ZXIgYXMgdGhlDQo+IG1pbmltdW0/KS4NCj4gSWYg
Y29uZi1zYW5pdHkgdGFrZXMgNSBob3VycyBpbiB0aGlzIHNldHVwIChjcHUgb3ZlcmNvbW1pdCBt
YWtpbmcNCj4gdGhpbmdzIHNsb3cgYW5kIHdoYXRub3QpIGFuZCB5b3UgYWx3YXlzIG9ubHkgcnVu
IGZvciBhbiBob3VyIC0gd2UgbmV2ZXINCj4gZ2V0IHRvIHRyeSBtb3N0IG9mIGNvbmYtc2FuaXR5
Lg0KPiANCj4gQWxzbyA1MCBzZXNzaW9ucyBvZiBjb25mLXNhbml0eSBydW5uaW5nIGluIHBhcmFs
bGVsIDF4IHZzDQo+IDEwIHNlc3Npb25zIHJ1bm5pbmcgY29uZi1zYW5pdHkgaW4gcGFyYWxsZWwg
NXggLSB0aGUgbGF0dGVyIHByb2JhYmx5DQo+IHdpbnMgY292ZXJhZ2Ugd2lzZSBiZWNhdXNlIG92
ZXIgdGltZSB0aGUgb3RoZXIgY29uZmxpY3RpbmcgVk1zIHdvdWxkDQo+IGRldmlhdGUgbW9yZSBz
byB0aGUgc3RyZXNzIHBvaW50cyBpbiB0aGUgY29kZSB3b3VsZCBmYWxsIG1vcmUgYW5kIG1vcmUN
Cj4gZGlmZmVyZW50bHksIEkgc3VzcGVjdCAoYnV0IHdlIGNhbiBwcm9iYWJseSB0ZXN0IHRoaXMg
YnkgcnVubmluZyBib3RoDQo+IHNldHVwcyBmb3IgbG9uZyBlbm91Z2ggaW4gcGFyYWxsZWwgb24g
dGhlIHNhbWUgY29kZSBhbmQgc2VlIGhvdyBtdWNoIG9mDQo+IGEgY3Jhc2ggcmF0ZSBkaWZmZXJl
bmNlIGl0IG1ha2VzKQ0KPiANCj4+IA0KPj4gQ2hlZXJzLCBBbmRyZWFzDQo+PiANCj4+Pj4gT24g
RmViIDMsIDIwMjUsIGF0IDE1OjMwLCBPbGVnIERyb2tpbiA8Z3JlZW5Ad2hhbWNsb3VkLmNvbT4g
d3JvdGU6DQo+Pj4gDQo+Pj4g77u/T24gTW9uLCAyMDI1LTAyLTAzIGF0IDIwOjI0ICswMDAwLCBP
bGVnIERyb2tpbiB3cm90ZToNCj4+PiANCj4+Pj4gYXQgJDExL2hvdXIgdGhlIG03YS5tZXRhbC00
OHhsIHdvdWxkIHRha2UgJDI2NCB0byBydW4gZm9yIGp1c3QNCj4+Pj4gb25lDQo+Pj4+IGRheSwN
Cj4+Pj4gYSB3ZWVrIGlzIGFuIGV5ZS13YXRlcmluZyAkMTg0OCwgc28gcnVubmluZyB0aGlzIGZv
ciBldmVyeSBwYXRjaA0KPj4+PiBpcw0KPj4+PiBub3QNCj4+Pj4gc3VwZXIgZWNvbm9taWNhbCBJ
J2Qgc2F5Lg0KPj4+IA0KPj4+IHgyZ2QgbWV0YWwgYXQgJDUuMzQgcGVyIGhvdXIgbWFrZXMgbW9y
ZSBzZW5zZSBhcyBpdCBoYXMgbW9yZSBSQU0NCj4+PiAoYW5kDQo+Pj4gNjQgQ1BVcyBpcyBhZGVx
dWF0ZSBJJ2Qgc2F5KSBidXQgc3RpbGwgcXVpdGUgcHJpY2V5IGlmIHlvdSB3YW50IHRvDQo+Pj4g
cnVuDQo+Pj4gdGhpcyBhdCBhbnkgc29ydCBvZiBzY2FsZS4NCj4+PiBfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXw0KPj4+IGx1c3RyZS1kZXZlbCBtYWlsaW5n
IGxpc3QNCj4+PiBsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZw0KPj4+IGh0dHA6Ly9saXN0
cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZw0KPiANCl9f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmx1c3RyZS1kZXZl
bCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcKaHR0cDovL2xpc3Rz
Lmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnCg==
