From: Gearing, Chris <chris.gearing@intel.com>
Date: Wed, 24 Oct 2012 20:02:08 +0000
Subject: [Lustre-devel] Language choice for Lustre tests
Message-ID: <EA3A770421F31B4BB895DD3AB9224495706F0E@fmsmsx119.amr.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathan,

I'm not 100% sure what you are proposing here, your LAD presentation suggested a 'tune-up' of the current test framework rather than a complete re-write. Which of the two are we discussing?

Which ever you are intending to undertake I think it is vital that before decisions are made on things such as languages a clear specification/definition of the activity is created and distributed. I am in fact working with Roman to bring such a document to the working group on the tune-up, making me somewhat confused about what is proposed here.

Going back to your LAD presentation for the tune-up your intention is to write some libraries to better address the requirements of the framework than is possible in bash, but those libraries would be called from the existing bash tests. This illustrates that the language used to develop the framework may not be the same language used for writing the tests, in fact I'm guessing that for both a tune-up and rewrite the requirements placed on the framework writer are different than those place on the test writer and so the languages required might well be different, and in fact if this is a tune-up then surely the tests must continue to be written in bash even if the libraries are in something more applicable, we do not want a single framework with mixed languages (do we?)

So to return to my original question could you please provide some greater depth of insight as to what you are embarking upon, and then we can make more objective input as the language required.

On the complete-rewrite topic, I will post the slides I sent you before LAD to the Whamcloud wiki and then provide a link to this list so that people can share our thoughts. (Network access prevents me doing this immediately)

Regards

Chris
---------------------------------------------------------------------
Intel Corporation (UK) Limited
Registered No. 1134945 (England)
Registered Office: Pipers Way, Swindon SN3 1RJ
VAT No: 860 2173 47

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
