#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
  # resources to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout.bundle/checkoutJSIntegration.js"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout.bundle/nativexo-manifest.json"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout.bundle/syrBundle.html"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout.bundle/assets"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/address_blue_border.imageset/address_blue_border.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/checkout_logo_large.imageset/checkout_logo_large.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/genericbank.imageset/genericbank.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_add_grey.imageset/icon_add_grey.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_checkbox_checked_blue.imageset/icon_checkbox_checked_blue.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_checkbox_default_grey.imageset/icon_checkbox_default_grey.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_chevron_backward_blue.imageset/icon_chevron_backward_blue.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_chevron_forward_blue.imageset/icon_chevron_forward_blue.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_close_cross_white.imageset/icon_close_cross_white.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_external_link_blue.imageset/icon_external_link_blue.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_footerlock_grey.imageset/icon_footerlock_grey.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_handshake_black.imageset/icon_handshake_black.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_lock_white.imageset/icon_lock_white.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_profile_phantom_black.imageset/icon_profile_phantom_black.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_profile_phantom_small_white.imageset/icon_profile_phantom_small_white.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_amex_small.imageset/img_fi_amex_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_bankofamerica_small.imageset/img_fi_bankofamerica_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_capitalone_small.imageset/img_fi_capitalone_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_chase_small.imageset/img_fi_chase_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_citibank_small.imageset/img_fi_citibank_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_discover_small.imageset/img_fi_discover_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_fifth_third_small.imageset/img_fi_fifth_third_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_huntington_small.imageset/img_fi_huntington_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_mastercard_small.imageset/img_fi_mastercard_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_pnc_small.imageset/img_fi_pnc_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_ppbalance_small.imageset/img_fi_ppbalance_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_regions_small.imageset/img_fi_regions_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_suntrust_small.imageset/img_fi_suntrust_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_td_ameritrade_small.imageset/img_fi_td_ameritrade_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_usaa_small.imageset/img_fi_usaa_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_usbank_small.imageset/img_fi_usbank_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_visa_small.imageset/img_fi_visa_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_wells_fargo_small.imageset/img_fi_wells_fargo_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/pp_logo_blue.imageset/pp_logo_blue.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/small_rectangle_fi.imageset/small_rectangle_fi.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/spinner_circular_border.imageset/spinner_circular_border.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/wallet_blue_border.imageset/wallet_blue_border.png"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout.bundle/checkoutJSIntegration.js"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout.bundle/nativexo-manifest.json"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout.bundle/syrBundle.html"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout.bundle/assets"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/address_blue_border.imageset/address_blue_border.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/checkout_logo_large.imageset/checkout_logo_large.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/genericbank.imageset/genericbank.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_add_grey.imageset/icon_add_grey.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_checkbox_checked_blue.imageset/icon_checkbox_checked_blue.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_checkbox_default_grey.imageset/icon_checkbox_default_grey.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_chevron_backward_blue.imageset/icon_chevron_backward_blue.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_chevron_forward_blue.imageset/icon_chevron_forward_blue.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_close_cross_white.imageset/icon_close_cross_white.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_external_link_blue.imageset/icon_external_link_blue.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_footerlock_grey.imageset/icon_footerlock_grey.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_handshake_black.imageset/icon_handshake_black.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_lock_white.imageset/icon_lock_white.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_profile_phantom_black.imageset/icon_profile_phantom_black.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/icon_profile_phantom_small_white.imageset/icon_profile_phantom_small_white.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_amex_small.imageset/img_fi_amex_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_bankofamerica_small.imageset/img_fi_bankofamerica_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_capitalone_small.imageset/img_fi_capitalone_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_chase_small.imageset/img_fi_chase_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_citibank_small.imageset/img_fi_citibank_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_discover_small.imageset/img_fi_discover_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_fifth_third_small.imageset/img_fi_fifth_third_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_huntington_small.imageset/img_fi_huntington_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_mastercard_small.imageset/img_fi_mastercard_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_pnc_small.imageset/img_fi_pnc_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_ppbalance_small.imageset/img_fi_ppbalance_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_regions_small.imageset/img_fi_regions_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_suntrust_small.imageset/img_fi_suntrust_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_td_ameritrade_small.imageset/img_fi_td_ameritrade_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_usaa_small.imageset/img_fi_usaa_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_usbank_small.imageset/img_fi_usbank_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_visa_small.imageset/img_fi_visa_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/img_fi_wells_fargo_small.imageset/img_fi_wells_fargo_small.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/pp_logo_blue.imageset/pp_logo_blue.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/small_rectangle_fi.imageset/small_rectangle_fi.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/spinner_circular_border.imageset/spinner_circular_border.png"
  install_resource "${PODS_ROOT}/PayPal.Checkout/pod/assets/PYPLCheckout/wallet_blue_border.imageset/wallet_blue_border.png"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi
