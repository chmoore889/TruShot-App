![Flutter Build](https://github.com/chmoore889/TruShot-App/workflows/Flutter%20Build/badge.svg?branch=release)
# TruShot

Many have tried to create algorithms to detect the presence of deepfakes with varying degrees of success. Personally, our team believes that this method of attack is futile. Deepfakes are created with GAN's, which simply get better over time with more training data. Soon enough, deepfakes will be completely indistinguishable from real images. What to do then?

Our solution attacks this problem before a deepfake can even get involved. Here's what it does:

When a user knows they want to take a photograph that they would like to be verified as authentic, they open our TruShot mobile app. They take the photo and we immediately upload it to our server.

Then, the user is given a 6 digit "ID". This "ID" corresponds to the image they just took.

Next, the user navigates to our website. On our home page, they can enter the ID.

From there, our website shows the image, along with a banner that verifies that it's authentic. We know it's authentic because it came from our server, and the only way to get onto that server is to upload straight out of the camera on our mobile app.

From that landing page, the user can copy an "embed code" that they can use to embed the image and banner into their website. We can see this embed mechanism be used in news articles, blogs, or even become integrated into twitter to automatically show our banner.
