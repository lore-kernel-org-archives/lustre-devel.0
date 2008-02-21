From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Thu, 21 Feb 2008 16:26:07 +0100
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47AAE307.9040305@cea.fr>
References: <47AAE307.9040305@cea.fr>
Message-ID: <47BD980F.50201@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

I've got several wondering about some specific point in HSM 
implementation and I would like your opinion about them.

Coordinator:

This element will manage migration externally (HSM) and internally of 
Lustre (space balancing?). Is the current API acceptable (specific calls 
for external migration, and other ones for internal migration)? The best 
way could have been to have generic call for migration, but we must also 
have generic objects to describe the migration sources and destinations 
and those are not simples. We finally conclude with the API presented in 
the HLD document. Tell me if this is *really* a bad idea or if only 
adjustments are needed.

We presented two modes of migration, explicit and implicit migrations. 
The first one result of an administrative request, the second one was 
triggered automatically (cache miss by example). Is that ok? (See the 
doc for all details).

Agent:

It seems, to support Lustre internal migration, you have planned to 
implement specific Agents which will reside on OST. HSM will need 
specific agent on clients. Do those two kinds of agent are acceptable ? 
The current API only describe HSM-based agent. Maybe we should think of 
a generic agent framework and add specialized implementations for 
ost,hsm,etc ?



-- 
Aurelien Degremont
CEA
