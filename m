Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0C5A8CDD552
	for <lustre-devel@archiver.kernel.org>; Wed, 18 Sep 2024 19:22:55 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4X87pR1hHsz1xNj;
	Wed, 18 Sep 2024 12:22:55 -0700 (PDT)
Received: from mx0f-00379502.gpphosted.com (mx0f-00379502.gpphosted.com
 [67.231.155.129])
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id
 4X87pQ03JZz1xFd
 for <lustre-devel@lists.lustre.org>; Wed, 18 Sep 2024 12:22:53 -0700 (PDT)
Received: from pps.filterd (m0422210.ppops.net [127.0.0.1])
 by mx0f-00379502.gpphosted.com (8.18.1.2/8.18.1.2) with ESMTP id
 48IDZmRA008737
 for <lustre-devel@lists.lustre.org>; Wed, 18 Sep 2024 12:22:53 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=llnl.gov;
 h=from : to : cc :
 subject : date : message-id : content-type : mime-version;
 s=02022021-podllnl; bh=dZzi1bH9wKxw/SnFDomPoriDBkW5BOity2BG9uwaylQ=;
 b=tnmNW/eh5tVvaibLZekB3NHFfYJszjhf+TFwoNVLN81nqWEUU84C1aNM2JFgCvfnBzG7
 wu2EJrdr4ma0bVenbk4BzjCZopBiM6KpKYInA/XzMSIm89ujbZmRC+LzOCJz5yRk3fcy
 CRmreWF0medzN8U1PZJ0h9tyjNLouZed9Wq90mSEf8jeuDaaM/arjeiMsQNRj0x8OGyc
 H84jeioPJJI42i9GVTYxN+bNprnjTreK2b4lV0oTUxvBz3FRimfl+PUaktNXpaDkhDQq
 ctt8O8xddsQEQyUt/mUcPqail11SyeFMyDG+9rjJjdbXMvRY9O8m7S9w9/SjWWgPqxXK PQ== 
Received: from bn8pr09cu001.outbound.protection.outlook.com
 (mail-eastus2azlp17012051.outbound.protection.outlook.com [40.93.12.51])
 by mx0f-00379502.gpphosted.com (PPS) with ESMTPS id 41qyvjgurh-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
 for <lustre-devel@lists.lustre.org>; Wed, 18 Sep 2024 12:22:52 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=rjnWfmNPqsiD/xqdXKxIKvbkqbdP+X/UyfTBMJ+FpKqUWDTBgjDG07Z73GQtkUyPXVziL2b+jXFbPSzHLzV2QVYo6aNLbnJ/rsNvANw9MT+Sz9cR0Oygo8UAamxgbAsW3w6Tyx/CZUtpeXL6M++NF7t9eFOimfVI2XCS9qdKaNKR13Oc2QSk/ZByi6kkjs9fsaGNshdRexispWF5Zi9h3YfuaG1orTOJIOgVgL+aFvHGIvUXYA87OGuk2zfJNc++LuNR/Ee2BkR+aEf+QCe6PiW3pG8Vz2Wd07UtWt6HyEchGe6X1kP/HeyssTMx6VEJTzsN+H9Tnnp5AVUKo/dJvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=dZzi1bH9wKxw/SnFDomPoriDBkW5BOity2BG9uwaylQ=;
 b=gsD+PqwpLUGnooDHQhENo82TMnz8NALw4frVkzXgO1HJwZkAMdFbMNv92mkRHCiizpBAXYgZ7NkoOiOdv2DdrSJ4KRN9ioxN7ldYKQpNXtn6ABcmnX0B+QlVU3SkgJak8EElJiJZYOAQFjE7jn+AbmsFuztxTsXdzP3B6yknOmaxOstzKiuM1BFB0/0v9jJQl3TzAYHzCDaOfVYGYSv+C80bp0nBzTLv+9nB7L/DC7B8J5te9dYXQrryCPvJQNVdMUfSiuPavt4tYe1EURx3ofHu0eTljDfhlOO2aWN6QDJQ/M2VJqA1qRj+dHdZ95oqEPJbvEA5nuBLVGzyPeJbWw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=llnl.gov; dmarc=pass action=none header.from=llnl.gov;
 dkim=pass header.d=llnl.gov; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=doellnl.onmicrosoft.com; s=selector1-doellnl-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dZzi1bH9wKxw/SnFDomPoriDBkW5BOity2BG9uwaylQ=;
 b=PRkGBvgPBcoyOqroAGcvWC362GY4ri4mLP388AIaqY5Bv/0CMSs18/gcfWr2FrU67ELP51w5elYPm5sLEd3GfFlCEHq7w3LYj6Pno21koHVmT+dXMJisJssuWCL5xa0Okhd/JXRtTiU6aiFVqGbOqSOXgaySwaYyxwJthzrD8Mc=
Received: from SJ0PR09MB6814.namprd09.prod.outlook.com (2603:10b6:a03:26b::22)
 by SA1PR09MB10318.namprd09.prod.outlook.com (2603:10b6:806:288::19)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7982.16; Wed, 18 Sep
 2024 19:22:50 +0000
Received: from SJ0PR09MB6814.namprd09.prod.outlook.com
 ([fe80::47ee:c845:b41b:7fdf]) by SJ0PR09MB6814.namprd09.prod.outlook.com
 ([fe80::47ee:c845:b41b:7fdf%5]) with mapi id 15.20.7982.016; Wed, 18 Sep 2024
 19:22:50 +0000
From: "Carbonneau, Eric Joseph Jean" <carbonneau1@llnl.gov>
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: LU-17573. lets use ext4 limit for uninitiated object.
Thread-Index: AQHbCf8v6sG78rLYzkGal9dk48MLOg==
Date: Wed, 18 Sep 2024 19:22:50 +0000
Message-ID: <SJ0PR09MB6814F6FB9FEBD143AEC3993395622@SJ0PR09MB6814.namprd09.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SJ0PR09MB6814:EE_|SA1PR09MB10318:EE_
x-ms-office365-filtering-correlation-id: c66d665f-be27-4222-851c-08dcd8174917
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;ARA:13230040|366016|1800799024|38070700018;
x-microsoft-antispam-message-info: =?us-ascii?Q?dsCAk3GMFDxciqFeQ6rPXrfQygcAoh+PTusfkq2iZ8RASAiC1IPL/GYJyUWt?=
 =?us-ascii?Q?lCzLaDy4PLNbA/hTjjDCmr21j33vCgsb/2XJFG575Gxm1WEqxm3rCiQGdiLH?=
 =?us-ascii?Q?Lb/7Q2vibwiQlFOOBUcYyc2Y2v8WMEeecIm8JZDsACiHQYO31cncSPBhf+26?=
 =?us-ascii?Q?2LiiRZzLdP63o/4IOWIUGiRD/JtC+ST4niKmMxeuSzYpUBQQtT5dX2dfe8nS?=
 =?us-ascii?Q?aB7J/F/JBkhaq5/mzt7KxfICLvjdCsJfa2UmW84IIpLzr5WAWfMf1w8CZ8dq?=
 =?us-ascii?Q?cgz25Lv9AnJVQmMufcn6LBmVRC+qDgMQhEg1KgyevOzBfVPux70CVNqIx6u2?=
 =?us-ascii?Q?x3ZHRw17arBbWWDa3visVzQmh6i67RUp+vcx8RY9gE/+24T9dRqqg9lVjENA?=
 =?us-ascii?Q?jchBXBbYIEqKw2GMakKkWbVAZvrkxtRHw8IN2gvRadLGvhM/zYqvganvuxVo?=
 =?us-ascii?Q?imPZmic00vNazxINWRj/kXPp49DAinoyJ3jB+UW8F3SrpcRM1fyCJqwS94Rj?=
 =?us-ascii?Q?cuAQNZsghEhmXtHv5X+ms9dDJE3+hV31BUjSu8cvpYpQHWTA9athr+RZjtJ0?=
 =?us-ascii?Q?P4u20YU/Dl5f7rpIGAPOvTqj7Lxa2M2d1WpVrbOI/WS0QEPCTdKkD8wy8YtP?=
 =?us-ascii?Q?ZT6YFwIx+U7u1s8axJD3BdRNGbolyPIlrjWBuo1u3+Nlvp87v9DalZp2uRMd?=
 =?us-ascii?Q?ojDFaVz4CaXIgs19Oawo3EOLwIhnHD70Bn+8tf7a9VwchpBz9nmWePHbU/nU?=
 =?us-ascii?Q?nvRYx5W6pcacJN1UnDNvMkxWQbNnui3EBsJXAoG9XKT6s8RZscMUOR2mX3th?=
 =?us-ascii?Q?rTyczyDHi/729nnjUBOZs+gJREdak35pXrBusRslwGjQVdpQWGHHIgQUQ/Lh?=
 =?us-ascii?Q?Y6WflBnQ63vZj4iAuKbufiLwn2Dy9Er9lMDF+e3cwtaa112NMNSPNbKb9sdP?=
 =?us-ascii?Q?YUy8DdTm9rkahnBFNHEry7sqoj+4kVOWHYGM66Y1gr9hU6EIuSjJyItBtg50?=
 =?us-ascii?Q?ASIJSru9DoQulUKtrzoZVq6+96OQ8DHZVx/tjbKcFgHrg3SkuRU2xLfPN09f?=
 =?us-ascii?Q?oy8JC84O7UkW5AfJlIuAiqtaeAqoiAWiN9P+/ZgV4lnuI/w/Ptz+At5qJek6?=
 =?us-ascii?Q?XjZPGu30/tXc6hUjnXG6TvcQX6gbkuE13GDjqZGmzQUHsBs8nSI3gHe4byUi?=
 =?us-ascii?Q?U0PgEA+4mK9D9Y507rPVHScezv0l02zyho/NrI1MTUINQoKbGfJnL5TAVST8?=
 =?us-ascii?Q?2RLuvr9KT2ruy1nNldQq8YE6S618ujxjaVOGsRemmX5pt95ohQLg73Es3es9?=
 =?us-ascii?Q?xcZW1OF8fvFQu5/gWrRslLff3+PRSXZgow/3Vkvte6+Un3oIRsRVfKuNAQzl?=
 =?us-ascii?Q?dwAIUm4n3gkxhazPwUI9BTwDnCidqvrhuNSu1shzorpS+afTpg=3D=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SJ0PR09MB6814.namprd09.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(38070700018); DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?LgeJ5W/k1+VxbRSHqdvaRM2XxwEvyDsbALxzPvcLIMrN8vifjNrQZBfrcU1s?=
 =?us-ascii?Q?3AkLa2N4MHdlwAUI/8ph/qkDWGsTUnPb0z9O3d4Q6c2AykqWBgvzTKtqRdMr?=
 =?us-ascii?Q?/Ccy3ZJkyb/IgGwoC7Ikrzq00q3I5bqhlP4/DW3CtUR/b30G8ukEkCmPLE/F?=
 =?us-ascii?Q?GpeRuv58OsIo1DzX4U8fJQ/iK3iVH+Ow3nUpzFskT1X/LNyfDyIGVYZloN3f?=
 =?us-ascii?Q?5P9h2vuHiFVLzAN9DBQ32ezL4LNGErUsjITH19j3ZXu9k2zUU+gVdWQVoaV+?=
 =?us-ascii?Q?9ob0pK5zAY+7dZby3g7x4mqVX6atmiq6MrC4pZo1w0QXjUBCFWBoWnDSz2by?=
 =?us-ascii?Q?zMLyuPapY2BSdyafZBnkrQChHkxl5M5XZB9jDVClebEzSx99dj2h9fBvG+z8?=
 =?us-ascii?Q?5l2okdqcf4uoTglbqXQpL1UHeAeFO5dhcgz0XMxP+lkcQKQpuoHjjDrq8Bvk?=
 =?us-ascii?Q?vYJFosalkZWL0AAdgZzQCfAo0sWXffktMQw5SCrItMfxZ9MdzZ9sMsaLnfCz?=
 =?us-ascii?Q?FcbZucnc+iVqOD5gibxk2ldroiacdy2zRzHcLQNTSNNRfeC105y98b9ZejNj?=
 =?us-ascii?Q?kl/mNk0Wt+0ckJzwZzSWtulAq2RKtX6+t7yHc8WLXYpaOKWEiZDRCPBIo64f?=
 =?us-ascii?Q?DN3NVF63ekLoq9jgRp8I2dfG6mncCaLTrWU4pYoKc4eWimbHGZc9vExJZzfl?=
 =?us-ascii?Q?c+lGjATSFmk+s/NCA/u53ZANnKCo4Tt4h77OIMqjo4xOlec4pExaaQNkCImw?=
 =?us-ascii?Q?VOIvFxTK7B0NfYEgkiMuKzHZi7Tc6fLp5zcmcqiezIrfbj9RbXgBX49Ljyzg?=
 =?us-ascii?Q?Ix638xs6YYYs1/HG7gweCGzKz/Mt+uPK5UXsj60N/CGvc/LA16RPRS4bGRW/?=
 =?us-ascii?Q?y0JCxQMTcUimOcWklfJDdHhdpU8R7sPffMs8c/3Hwi9y194ucD/soTlrEFzD?=
 =?us-ascii?Q?jNFFvQuMzMRV0FGFaRcPHhTx5sBSGIQK3sXRTRC5D1VGm+/OPpMXxcAL20I5?=
 =?us-ascii?Q?XLoxiv3olYMriGX+qiT8LZ2uv0tCivFyrQYksE9CvR/6aMI8mEI//6qs18tH?=
 =?us-ascii?Q?M+iEEUrVL6m0xfMFELyur4iOTNSixBLTZqMaHe6y/XYv4yctug/nft3ofPdf?=
 =?us-ascii?Q?TfE1LUQEZnnXOELbqVW8kjziDQwGfcO+g+jZrUC4ttBXfhc+RbIOOzymuX5u?=
 =?us-ascii?Q?6jCsjMUkYcp0QUCZnkj5BBPPrGXHCSH10GjrZt3CbXobyH6YoHhEQFMPRh7V?=
 =?us-ascii?Q?kE3nOw2vu4FT2qJ8wLlSDox5Mntcjqw22Ve3LDojGgpMCx2YEXse0LLOCDx2?=
 =?us-ascii?Q?YjB++o1uiVVTTUxqtwHfUyutTB6N2p02UBx1F9aIpSl50HUKqdQ2MSPdnf05?=
 =?us-ascii?Q?4F/9j//GhrnWnADKBmR2+whzFgRrHeRHNGbYEyZbG4AR/xf8OoMPKCQBXN8m?=
 =?us-ascii?Q?SGYvl5iciEpWXbA/jhVu5OSspnYmkeqtOglCvvTn20NRP646erJwYxM+FLIq?=
 =?us-ascii?Q?eFzan1epbNCXdvK/A6GJCU0G56qz4Rkx7y6MHhAH6+6vRetwZUaI1Di2VFD5?=
 =?us-ascii?Q?jD//qva5DQjGlBLUdjDu8wDrd0ASlPnJZ8A+pXtQj79BpqdlNMPEMDbgXj4O?=
 =?us-ascii?Q?+g=3D=3D?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: HeV50D9lUjSqHPCUZ4YsyOZaJPhRTJl+l68U70ptwlS4s2CRcLo9Cu9pGPuaLmQY1r8J01UdMbmy1500t5BQZvQE1cVaXLqSYJSLcGy+TKsd/sFK8pUe7hfJ8zPEfKY6Q4KP9UilLX9pEDh16dJwexWFpxRJ3Kt6VVq6n0vrWw3ogNY2iFNkO9gvNFdCA40gbZYfrAF/Y0zPvjUgC//7eSWbyFjsS3xeeqYYSmhRmyCN+Gk0RsbmCpE14WzWfA4qH6LdiduwupwMT/+UCA+w4Ah7FmhqmQ47RcE+Jw7ElcSao77fFjUiffhriOpPyIGv+7a/5Yj5km/iawh5G++FW3iEfcbSaOD8p9MoKN54rLz2e+tbmg2ScxMgLU2Goud90gUjUViD6MYjElZlLjkmBWsVt7VdJv/hh2a9Y1YTZPgiOjokUa18p/oI5ZoBg+OgqkM7atqOqYAmcCkW418qCNdd8o6PouLIboH7N6s0SjLPT4n+CAySqeqigZ8yMeF1Rwboo/v6Y1kPlBcL1qB3GL86XuX54ziTA1Vu/MEsOiRVJ7mMqCRg3sbaScmS76PYfg4LPS5DFer7lwt4GAYgnI9ejRyUYG+v6l6rvgsMjSzES5JFAZYu2oeEYjkNCwME2UawCaKmbovIXP3HullRMQ==
X-OriginatorOrg: llnl.gov
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SJ0PR09MB6814.namprd09.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c66d665f-be27-4222-851c-08dcd8174917
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Sep 2024 19:22:50.1416 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a722dec9-ae4e-4ae3-9d75-fd66e2680a63
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR09MB10318
X-Proofpoint-ORIG-GUID: Fpjy7WQNADKCced5OWCQAj9txSpbT5q1
X-Proofpoint-GUID: Fpjy7WQNADKCced5OWCQAj9txSpbT5q1
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1051,Hydra:6.0.680,FMLib:17.12.60.29
 definitions=2024-09-18_14,2024-09-18_01,2024-09-02_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 bulkscore=0 clxscore=1011
 malwarescore=0 priorityscore=1501 mlxlogscore=833 impostorscore=0
 mlxscore=0 adultscore=0 suspectscore=0 lowpriorityscore=0 spamscore=0
 phishscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2408220000 definitions=main-2409180127
Subject: [lustre-devel] LU-17573. lets use ext4 limit for uninitiated object.
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
Content-Type: multipart/mixed; boundary="===============0965261847027910565=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0965261847027910565==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_SJ0PR09MB6814F6FB9FEBD143AEC3993395622SJ0PR09MB6814namp_"

--_000_SJ0PR09MB6814F6FB9FEBD143AEC3993395622SJ0PR09MB6814namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

We encountered a similar issue after setting PFL and all OSTs ended up with=
 a file too large error: (Lustre 2.15.5)
here is how we reproduced the error:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
[faaland1@mutt9 pfltest] $mkdir nopfl pfl-one pfl-two
[faaland1@mutt9 pfltest] $lfs setstripe -E 256G -c2 -S 16M -E -1 -c -1 pfl-=
two
[faaland1@mutt9 pfltest] $lfs setstripe -E -1 -c -1 pfl-one
[faaland1@mutt9 pfltest] $lfs setstripe -c -1 -S 16M nopfl
[faaland1@mutt9 pfltest] $pwd
/p/lflood/faaland1/test/pfltest
[faaland1@mutt9 pfltest] $lfs check servers .
lflood-OST0000-osc-ff1a28194597d000 active.
lflood-OST0001-osc-ff1a28194597d000 active.
lflood-OST0002-osc-ff1a28194597d000 active.
lflood-OST0003-osc-ff1a28194597d000 active.
lflood-MDT0000-mdc-ff1a28194597d000 active.
lflood-MDT0001-mdc-ff1a28194597d000 active.
lflood-MDT0002-mdc-ff1a28194597d000 active.
lflood-MDT0003-mdc-ff1a28194597d000 active.
MGC172.19.1.133@o2ib100 active.
[faaland1@mutt9 pfltest] $for xx in *; do echo $xx; dd if=3D/dev/zero bs=3D=
1 seek=3D$((8*2))T of=3D${xx}/16TB count=3D1; echo; done 2>&1
nopfl
1+0 records in
1+0 records out
1 byte copied, 0.0006174 s, 1.6 kB/s
pfl-one
1+0 records in
1+0 records out
1 byte copied, 0.000456144 s, 2.2 kB/s
pfl-two
dd: failed to truncate to 17592186044416 bytes in output file 'pfl-two/16TB=
': File too large
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D


If one of the watcher could confirm/review the current fix for this ticket =
really addresses the error we encountered.

thanks

-eric

--_000_SJ0PR09MB6814F6FB9FEBD143AEC3993395622SJ0PR09MB6814namp_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" xmlns:w=3D"urn:sc=
hemas-microsoft-com:office:word" xmlns:m=3D"http://schemas.microsoft.com/of=
fice/2004/12/omml" xmlns=3D"http://www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Aptos;
	panose-1:2 11 0 4 2 2 2 2 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	font-size:12.0pt;
	font-family:"Aptos",sans-serif;
	mso-ligatures:standardcontextual;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;
	mso-ligatures:none;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style>
</head>
<body lang=3D"EN-US" link=3D"#467886" vlink=3D"#96607D" style=3D"word-wrap:=
break-word">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span style=3D"font-size:16.0pt">We encountered a si=
milar issue after setting PFL and all OSTs ended up with a file too large e=
rror: (Lustre 2.15.5)<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:16.0pt">here is how we repr=
oduced the error:<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D<br>
[faaland1@mutt9 pfltest]&nbsp;$mkdir nopfl pfl-one pfl-two<br>
[faaland1@mutt9 pfltest]&nbsp;$lfs setstripe -E 256G -c2 -S 16M -E -1 -c -1=
 pfl-two<br>
[faaland1@mutt9 pfltest]&nbsp;$lfs setstripe -E -1 -c -1 pfl-one<br>
[faaland1@mutt9 pfltest]&nbsp;$lfs setstripe -c -1 -S 16M nopfl<br>
[faaland1@mutt9 pfltest]&nbsp;$pwd<br>
/p/lflood/faaland1/test/pfltest<br>
[faaland1@mutt9 pfltest]&nbsp;$lfs check servers .<br>
lflood-OST0000-osc-ff1a28194597d000 active.<br>
lflood-OST0001-osc-ff1a28194597d000 active.<br>
lflood-OST0002-osc-ff1a28194597d000 active.<br>
lflood-OST0003-osc-ff1a28194597d000 active.<br>
lflood-MDT0000-mdc-ff1a28194597d000 active.<br>
lflood-MDT0001-mdc-ff1a28194597d000 active.<br>
lflood-MDT0002-mdc-ff1a28194597d000 active.<br>
lflood-MDT0003-mdc-ff1a28194597d000 active.<br>
MGC172.19.1.133@o2ib100 active.<br>
[faaland1@mutt9 pfltest]&nbsp;$for xx in *; do echo $xx; dd if=3D/dev/zero =
bs=3D1 seek=3D$((8*2))T of=3D${xx}/16TB count=3D1; echo; done 2&gt;&amp;1<b=
r>
nopfl<br>
1+0 records in<br>
1+0 records out<br>
1 byte copied, 0.0006174 s, 1.6 kB/s<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:16.0pt">pfl-one<br>
1+0 records in<br>
1+0 records out<br>
1 byte copied, 0.000456144 s, 2.2 kB/s<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:16.0pt">pfl-two<br>
dd: failed to truncate to 17592186044416 bytes in output file 'pfl-two/16TB=
': File too large<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<o:p></o:p><=
/span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:16.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:16.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><b><span style=3D"font-size:18.0pt">If one of the wa=
tcher could confirm/review the current fix for this ticket really addresses=
 the error we encountered.
<o:p></o:p></span></b></p>
<p class=3D"MsoNormal"><span style=3D"font-size:16.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:16.0pt">thanks<o:p></o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt">-eric<o:p></o:p></s=
pan></p>
</div>
</body>
</html>

--_000_SJ0PR09MB6814F6FB9FEBD143AEC3993395622SJ0PR09MB6814namp_--

--===============0965261847027910565==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0965261847027910565==--
