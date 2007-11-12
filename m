From: Danny Sternkopf <dsternkopf@hpce.nec.com>
Date: Mon, 12 Nov 2007 17:10:22 +0100
Subject: [Lustre-devel] Lustre - HA:  lc_hb - ha.cf configuration
In-Reply-To: <4721B252.1010808@hpce.nec.com>
References: <4721B252.1010808@hpce.nec.com>
Message-ID: <47387AEE.3000203@hpce.nec.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I dont' understand how the ha.cf configuration works.
The file is created as follows:
python /usr/lib64/heartbeat/haresources2cib.py --stdout
/tmp/heartbeat/haresources.lustre > /tmp/heartbeat/cib.xml.lustre

Then it is transferred to the corresponding node.

haresources2cib.py uses /etc/ha.d/ha.cf which is different on other
nodes. I think the cib.xml must be created on the local host.

Or there should be the possibility to specify a node-specific ha.cf for
HA configuration creation.

Best regards,

Danny
-- 
Danny Sternkopf                         dsternkopf at hpce.nec.com
NEC HPC Europe GmbH,           http://www.teraflop-workbench.de
Stuttgart, Germany phone: +49-711-68770-35 fax: +49-711-6877145
