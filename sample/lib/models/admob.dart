import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMob {
  static final AdMob _singleton = AdMob._internal();

  InterstitialAd? _interstitialAd;

  factory AdMob() {
    return _singleton;
  }

  AdMob._internal();

  bool _isLoaded = false;

  bool get isLoaded {
    return _isLoaded;
  }

  void setIsLoaded(bool val) {
    _isLoaded = val;
  }

  bool shouldAdBePlayed() {
    return false;
  }


  InterstitialAd? get interstitialAd => _interstitialAd;

  Future<InterstitialAd?> createInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: InterstitialAd.testAdUnitId,
      request: const AdRequest(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        nonPersonalizedAds: true,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (loadedAd) {
          _isLoaded = true;
          _interstitialAd = loadedAd;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoaded = false;
          _interstitialAd = null;
        },
      ),
    );

    return _interstitialAd;
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}